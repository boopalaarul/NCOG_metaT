### Data

Shared data resources (contig names, contig annotations, contig frequencies) are in `data/`.

### Analysis

ALDEx2 scale modeling is a DEVELOPMENT feature. It is not provided in the main ALDEx2 branch. 

It will produce different results from default ALDEx2 (which goes frequencies -> Dirichlet samples, (re?)samples of proportions for each feature -> CLR of sampled proportions -> variance within/between CLR coordinates). 

Therefore it has been provided its own folder for code and analysis results (`ALDEX_scale/`).

---
