echo -e "======\n Testing NF execution \n======" \
&& rm -rf test/results/ \
&& nextflow run vcf2pcp.nf \
	--vcffile test/data/sampleWGS.vcf.gz \
	--output_dir test/results \
	-resume \
	-with-report test/results/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag test/results/`date +%Y%m%d_%H%M%S`.DAG.html \
&& echo -e "======\n VCF2PCP: Basic pipeline TEST SUCCESSFUL \n======"
