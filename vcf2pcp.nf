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
 Judith Ballesteros Villascán (judith.vballesteros@gmail.com)
 Israel Aguilar-Ordonez (iaguilaror@gmail)

- Bioinformatics Development
 Judith Ballesteros Villascán (judith.vballesteros@gmail.com)
Israel Aguilar-Ordonez (iaguilaror@gmail)

- Nextflow Port
 Judith Ballesteros Villascán (judith.vballesteros@gmail.com)
 Israel Aguilar-Ordonez (iaguilaror@gmail)

=============================
Pipeline Processes In Brief:
.
Pre-processing:
_pre1_split_chromosomes
_pre2_simplify_removeLD
_pre3_rejoinvcf
_pre4_vcf2plink
_pre5_make_pedind
_pre6_make_pop_info

Core-processing:
_001_make_par_file_smartpca
_002_keep_autosomes
_003_run_admixture

Pos-processing
_post1_parallel_coordinate_plot
_post2_regional_pca
_post3_plot_admixture
_post4_plot_cvs
_post5_gather_admixture_plots
_postX_kmeans <- should probably be moved before the regional pca module, to see every pc angle with the cluster data as the tag file...

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

/* 	Process _pre1_split_chromosomes */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-split-chromosomes/*")
	.toList()
	.set{ mkfiles_pre1 }

process _pre1_split_chromosomes {

	publishDir "${intermediates_dir}/_pre1_split_chromosomes/",mode:"symlink"

	input:
	file vcf from vcf_inputs
	file mk_files from mkfiles_pre1

	output:
	file "*chunk*" into results_pre1_split_chromosomes mode flatten

	"""
	bash runmk.sh
	"""

}

/* 	Process _pre2_simplify_removeLD */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-simplifyVCF-removeLD/*")
	.toList()
	.set{ mkfiles_pre2 }

process _pre2_simplify_removeLD {

	publishDir "${intermediates_dir}/_pre2_simplify_removeLD/",mode:"symlink"

	input:
	file vcf from results_pre1_split_chromosomes
	file mk_files from mkfiles_pre2

	output:
	file "*.noLD.vcf" into results_pre2_simplify_removeLD

	"""
	export LD="${params.ld}"
	export WINDOW="${params.window}"
	export N_SITES="${params.n_sites}"
	bash runmk.sh
	"""

}

/* Gather every previous result from pre4 before rejoining */
results_pre2_simplify_removeLD
.toList()
.set{ all_chunks }

/* 	Process _pre3_rejoinvcf */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-rejoin-vcf/*")
	.toList()
	.set{ mkfiles_pre3 }

process _pre3_rejoinvcf {

	publishDir "${intermediates_dir}/_pre3_rejoinvcf/",mode:"symlink"

	input:
	file chunks from all_chunks
	file mk_files from mkfiles_pre3

	output:
	file "*.vcf" into results_pre3_rejoinvcf

	"""
	bash runmk.sh
	"""

}

/* 	Process _pre4_vcf2plink */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-vcf2PLINK/*")
	.toList()
	.set{ mkfiles_pre4 }

process _pre4_vcf2plink {

	publishDir "${intermediates_dir}/_pre4_vcf2plink/",mode:"symlink"

	input:
	file vcf from results_pre3_rejoinvcf
	file mk_files from mkfiles_pre4

	output:
	file "*.LD.maf_filtered*" into results_pre4_vcf2plink
	file "*.LD.maf_filtered.fam" into results_FAM

	"""
  export PLINK2="${params.plink2}"
	export MAF="${params.maf}"
	export THREADS_PLINK="${params.threads_plink}"
	bash runmk.sh
	"""

}

/* 	Process _pre5_make_pedind */

/* get the sample info file into a channel */
Channel
	.fromPath("${params.sample_info}*")
	.toList()
	.set{ sample_file }

/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-make-pedind/*")
	.toList()
	.set{ mkfiles_pre5 }

process _pre5_make_pedind {

	publishDir "${intermediates_dir}/_pre5_make_pedind/",mode:"symlink"

	input:
	file fam from results_FAM
	file reference from sample_file
	file mk_files from mkfiles_pre5

	output:
	file "*.pedind" into results_pre5_make_pedind

	"""
	export SAMPLE_INFO="${get_baseName(params.sample_info)}"
	bash runmk.sh
	"""
}

/* 	Process _pre6_make_pop_info */
/* get the sample info file into a channel */
Channel
	.fromPath("${params.region_tags}*")
	.toList()
	.set{ tag_file }

/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-make-pop-info/*")
	.toList()
	.set{ mkfiles_pre6 }

process _pre6_make_pop_info {

	publishDir "${intermediates_dir}/_pre6_make_pop_info/",mode:"symlink"

	input:
	file fam from results_FAM
	file reference from tag_file
	file mk_files from mkfiles_pre6
	output:
	file "*popinfo.txt" into results_pre6_make_pop_info

	"""
	export TAG_FILE="${get_baseName(params.region_tags)}"
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
  file bed from results_pre4_vcf2plink
  file pedind from results_pre5_make_pedind
  file mk_files from mkfiles_001

	output:
	file "*" into results_001_make_par_file_smartpca

	"""
	export PCA_NUMBER="${params.pca_number}"
	bash runmk.sh
	"""

}

/* 	Process _002_keep_autosomes */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-keep-autosomes/*")
	.toList()
	.set{ mkfiles_002 }

process _002_keep_autosomes {

	publishDir "${intermediates_dir}/${pipeline_name}-results/_002_keep_autosomes/",mode:"symlink"

	input:
  file bed from results_pre4_vcf2plink
  file mk_files from mkfiles_002

	output:
	file "*.autosomal.*" into results_002_keep_autosomes

	"""
	export PLINK2="${params.plink2}"
	export THREADS_PLINK="${params.threads_plink}"
	bash runmk.sh
	"""

}

/* 	Process _003_run_admixture */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-run-admixture/*")
	.toList()
	.set{ mkfiles_003 }

process _003_run_admixture {
	cache 'deep' //added since on testing we observed persistant process rerun despite of previous success
	publishDir "${params.output_dir}/${pipeline_name}-results/_003_run_admixture/",mode:"copy"

	input:
  file bed from results_002_keep_autosomes
  file mk_files from mkfiles_003

	output:
	file "*" into results_003_run_admixture
	file "*.log" into results_log

	"""
	export SEED_VALUE="${params.admixture_seed_value}"
	export ADMIXTURE_THREADS="${params.admixture_threads}"
	bash runmk.sh
	"""

}

/* 	Process _post1_parallel_coordinate_plot */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-parallel_coordinate_plot/*")
	.toList()
	.set{ mkfiles_post1 }

process _post1_parallel_coordinate_plot {

	publishDir "${params.output_dir}/${pipeline_name}-results/_post1_parallel_coordinate_plot/",mode:"copy"

	input:
  file evec from results_001_make_par_file_smartpca
  file mk_files from mkfiles_post1

	output:
	file "*" into results_post1_parallel_coordinate_plot mode flatten //required for propper gathering donwstream

	"""
	bash runmk.sh
	"""

}

///
/* 	Process _post2_regional_pca */

/* Gather results in a single channel */
results_post1_parallel_coordinate_plot
.toList()
.set{ inputs_for_post2 }

/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-regional-PCA/*")
	.toList()
	.set{ mkfiles_post2 }

process _post2_regional_pca {

	publishDir "${params.output_dir}/${pipeline_name}-results/_post2_regional_pca/",mode:"copy"

	input:
  file pca_files from inputs_for_post2
	file reference from tag_file
  file mk_files from mkfiles_post2

	output:
	file "*"

	"""
	export TAG_FILE="${get_baseName(params.region_tags)}"
	bash runmk.sh
	"""

}

/* 	Process _post3_plot_admixture */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-plot-admixture/*")
	.toList()
	.set{ mkfiles_post3 }

process _post3_plot_admixture {

	publishDir "${params.output_dir}/${pipeline_name}-results/_post3_plot_admixture/",mode:"copy"

	input:
  file admixture from results_003_run_admixture
	file popinfo from results_pre6_make_pop_info
  file mk_files from mkfiles_post3

	output:
	file "*.svg"
	file "*.rds" into results_post3_plot_admixture

	"""
	bash runmk.sh
	"""
}

/* 	Process _post4_plot_cvs */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-plot-cvs/*")
	.toList()
	.set{ mkfiles_post4 }

process _post4_plot_cvs {

	publishDir "${params.output_dir}/${pipeline_name}-results/_post4_plot_cvs/",mode:"copy"

	input:
  file log from results_log
  file mk_files from mkfiles_post4

	output:
	file "*" into results_post4_plot_cvs

	"""
	bash runmk.sh
	"""

}

/* _post5_gather_admixture_plots */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-gather-admixture-plots/*")
	.toList()
	.set{ mkfiles_post5 }

process _post5_gather_admixture_plots {

	publishDir "${params.output_dir}/${pipeline_name}-results/_post5_gather_admixture_plots/",mode:"copy"

	input:
  file allrds from results_post3_plot_admixture
  file mk_files from mkfiles_post5

	output:
	file "*.svg"

	"""
	bash runmk.sh
	"""

}

/* 	Process _postX_kmeans */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-k-means-analysis/*")
	.toList()
	.set{ mkfiles_postX }

process _postX_kmeans {

	publishDir "${params.output_dir}/${pipeline_name}-results/_postX_kmeans/",mode:"copy"

	input:
  file evec from results_001_make_par_file_smartpca
  file mk_files from mkfiles_postX

	output:
	file "*" into results_postX_kmeans

	"""
	bash runmk.sh
	"""

}
