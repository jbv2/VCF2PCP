#!/usr/bin/env nextflow

/*================================================================
The MORETT LAB presents...

  A vcf PCP pipeline.

==================================================================
Version: 0.0.1
Project repository:
==================================================================
Authors:

- Bioinformatics Design
 Israel Aguilar-Ordonez (iaguilaror@gmail)
 Judith Ballesteros Villascán (judith.vballesteros@gmail.com)

- Bioinformatics Development
 Israel Aguilar-Ordonez (iaguilaror@gmail)
 Judith Ballesteros Villascán (judith.vballesteros@gmail.com)

- Nextflow Port
 Israel Aguilar-Ordonez (iaguilaror@gmail)
 Judith Ballesteros Villascán (judith.vballesteros@gmail.com)

=============================
Pipeline Processes In Brief:
.
Pre-processing:
_pre1_vcf2plink
_pre2_make_pedind

Core-processing:
_001_make_par_file_smartpca

Pos-processing
_post1_parallel_coordinate_plot

================================================================*/

/* Define the help message as a function to call when needed *//////////////////////////////
def helpMessage() {
	log.info"""
  ==========================================
  A vcf PCP pipeline
  v${version}
  ==========================================

	Usage:

  nextflow run aims_frequencies.nf --vcffile <path to input 1> [--output_dir path to results ]

	  --vcffile    <- compressed vcf file for annotation;
				accepted extension is vcf.gz;
				vcf file must have a TABIX index with .tbi extension, located in the same directory as the vcf file
	  --output_dir     <- directory where results, intermediate and log files will bestored;
				default: same dir where --query_fasta resides
	  -resume	   <- Use cached results if the executed project has been run before;
				default: not activated
				This native NF option checks if anything has changed from a previous pipeline execution.
				Then, it resumes the run from the last successful stage.
				i.e. If for some reason your previous run got interrupted,
				running the -resume option will take it from the last successful pipeline stage
				instead of starting over
				Read more here: https://www.nextflow.io/docs/latest/getstarted.html#getstart-resume
	  --help           <- Shows Pipeline Information
	  --version        <- Show ExtendAlign version
	""".stripIndent()
}

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
version = "0.0.1"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
pipeline_name = "VCF2PCP"

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.vcffile = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.help = false //default is false to not trigger help message automatically at every run
params.version = false //default is false to not trigger version message automatically at every run

/*//////////////////////////////
  If the user inputs the --help flag
  print the help message and exit pipeline
*/
if (params.help){
	helpMessage()
	exit 0
}

/*//////////////////////////////
  If the user inputs the --version flag
  print the pipeline version
*/
if (params.version){
	println "VCF2PCP v${version}"
	exit 0
}

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by iaguilar at FEB 2019
*/
nextflow_required_version = '18.10.1'
/*
  Try Catch to verify compatible Nextflow version
  If user Nextflow version is lower than the required version pipeline will continue
  but a message is printed to tell the user maybe it's a good idea to update her/his Nextflow
*/
try {
	if( ! nextflow.version.matches(">= $nextflow_required_version") ){
		throw GroovyException('Your Nextflow version is older than Pipeline required version')
	}
} catch (all) {
	log.error "-----\n" +
			"  This pipeline requires Nextflow version: $nextflow_required_version \n" +
      "  But you are running version: $workflow.nextflow.version \n" +
			"  The pipeline will continue but some things may not work as intended\n" +
			"  You may want to run `nextflow self-update` to update Nextflow\n" +
			"============================================================"
}

/*//////////////////////////////
  INPUT PARAMETER VALIDATION BLOCK
  TODO (iaguilar) check the extension of input queries; see getExtension() at https://www.nextflow.io/docs/latest/script.html#check-file-attributes
*/

/* Check if vcffile provided
    if they were not provided, they keep the 'false' value assigned in the parameter initiation block above
    and this test fails
*/
if ( !params.vcffile ) {
  log.error " Please provide both, the --vcffile \n\n" +
  " For more information, execute: nextflow run vcf2pcp.nf --help"
  exit 1
}

/*
Output directory definition
Default value to create directory is the parent dir of --vcffile
*/
params.output_dir = file(params.vcffile).getParent()

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable (pipeline_name) defined by this Script

  This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*
Useful functions definition
*/
/* define a function for extracting the file name from a full path */
/* The full path will be the one defined by the user to indicate where the reference file is located */
def get_baseName(f) {
	/* find where is the last appearance of "/", then extract the string +1 after this last appearance */
  	f.substring(f.lastIndexOf('/') + 1);
}


/*//////////////////////////////
  LOG RUN INFORMATION
*/
log.info"""
==========================================
The Annotation Pipeline for gnomAD V3 frequencies
v${version}
==========================================
"""
log.info "--Nextflow metadata--"
/* define function to store nextflow metadata summary info */
def nfsummary = [:]
/* log parameter values beign used into summary */
/* For the following runtime metadata origins, see https://www.nextflow.io/docs/latest/metadata.html */
nfsummary['Resumed run?'] = workflow.resume
nfsummary['Run Name']			= workflow.runName
nfsummary['Current user']		= workflow.userName
/* string transform the time and date of run start; remove : chars and replace spaces by underscores */
nfsummary['Start time']			= workflow.start.toString().replace(":", "").replace(" ", "_")
nfsummary['Script dir']		 = workflow.projectDir
nfsummary['Working dir']		 = workflow.workDir
nfsummary['Current dir']		= workflow.launchDir
nfsummary['Launch command'] = workflow.commandLine
log.info nfsummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "\n\n--Pipeline Parameters--"
/* define function to store nextflow metadata summary info */
def pipelinesummary = [:]
/* log parameter values beign used into summary */
pipelinesummary['VCFfile']			= params.vcffile
// pipelinesummary['vars per chunk']			= params.variants_per_chunk
pipelinesummary['Results Dir']		= results_dir
pipelinesummary['Intermediate Dir']		= intermediates_dir
/* print stored summary info */
log.info pipelinesummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "==========================================\nPipeline Start"

/*//////////////////////////////
  PIPELINE START
*/

/*
	READ INPUTS
*/

/* Load vcf file into channel */
Channel
  .fromPath("${params.vcffile}*")
	.toList()
  .set{ vcf_inputs }

/* 	Process _pre1_vcf2plink */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-vcf2PLINK/*")
	.toList()
	.set{ mkfiles_pre1 }

process _pre1_vcf2plink {

	publishDir "${intermediates_dir}/_pre1_vcf2plink/",mode:"symlink"

	input:
	file vcf from vcf_inputs
	file mk_files from mkfiles_pre1

	output:
	file "*.LD.maf_filtered*" into results_pre1_vcf2plink
	file "*.LD.maf_filtered.fam" into results_FAM

	"""
  export PLINK="${params.plink}"
	export LD="${params.ld}"
	export WINDOW="${params.window}"
	export MAF="${params.maf}"
	export N_sites="${params.n_sites}"
	export THREADS_PLINK="${params.threads_plink}"
	bash runmk.sh
	"""

}

/* 	Process _pre2_make_pedind */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-make-pedind/*")
	.toList()
	.set{ mkfiles_pre2 }

process _pre2_make_pedind {

	publishDir "${intermediates_dir}/_pre2_make_pedind/",mode:"symlink"

	input:
	file fam from results_FAM
	file mk_files from mkfiles_pre2

	output:
	file "*.pedind" into results_pre2_make_pedind

	"""
	export TSV="${params.tsv}"
	bash runmk.sh
	"""

}

/* 	Process _001_make_par_file_smartpca */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-make-par-file_smartpca/*")
	.toList()
	.set{ mkfiles_001 }

process _001_make_par_file_smartpca {

	publishDir "${params.output_dir}/${pipeline_name}-results/_001_make_par_file_smartpca/",mode:"copy"

	input:
  file bed from results_pre1_vcf2plink
  file pedind from results_pre2_make_pedind
  file mk_files from mkfiles_001

	output:
	file "*" into results_001_make_par_file_smartpca

	"""
	export PCA_NUMBER="${params.pca_number}"
	bash runmk.sh
	"""

}

/* 	Process _post1_parallel_coordinate_plot */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-parallel_coordinate_plot_prototipo_de_modulo/*")
	.toList()
	.set{ mkfiles_post1 }

process _post1_parallel_coordinate_plot {

	publishDir "${params.output_dir}/${pipeline_name}-results/_post1_parallel_coordinate_plot/",mode:"copy"

	input:
  file evec from results_001_make_par_file_smartpca
  file mk_files from mkfiles_post1

	output:
	file "*_plot.*" into results_post1_parallel_coordinate_plot

	"""
	bash runmk.sh
	"""

}
