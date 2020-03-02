# nf-VCF2PCP

A pipeline that makes Parallel Coordinate Plot from VCF.

This pipeline uses PLINK. It can work with v1.9 or 2.0, but consider that v2 lets the use of multiple threads.

---
## Requirements
#### Compatible OS*:
* [Ubuntu 18.04.03 LTS](http://releases.ubuntu.com/18.04/)

\* nf-VCF2PCP may run in other UNIX based OS and versions, but testing is required.

#### Software:
| Requirement | Version  | Required Commands * |
|:---------:|:--------:|:-------------------:|
| [bcftools](https://samtools.github.io/bcftools/) | 1.9-220-gc65ba41 | bcftools |
| [plink](https://www.cog-genomics.org/plink/2.0/) | 1.9 & 2 | plink |
| [Eigensoft](https://data.broadinstitute.org/alkesgroup/EIGENSOFT/) | 6.1.4 | smartpca |
| [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) | 19.04.1.5072 | nextflow |
| [Plan9 port](https://github.com/9fans/plan9port) | Latest (as of 10/01/2019 ) | mk \** |
| [R](https://www.r-project.org/) | 3.4.4 | ** See R scripts |

\* These commands must be accessible from your `$PATH` (*i.e.* you should be able to invoke them from your command line).  

\** Plan9 port builds many binaries, but you ONLY need the `mk` utility to be accessible from your command line.

---

### Contact
If you have questions, requests, or bugs to report, please email
<judith.vballesteros@gmail.com>

#### Dev Team
Israel Aguilar-Ordonez <judith.vballesteros@gmail.com>   