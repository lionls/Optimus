#! /bin/bash

#PBS -A "MModul-GMAS"
#PBS -l select=1:ncpus=1:mem=64gb
#PBS -l pmem=64gb
#PBS -l walltime=47:59:00
#PBS -q CUDA
#PBS -o Train_preprocess.out

set -e
export LOGFILE=$PBS_O_WORKDIR/$PBS_JOBNAME"."$PBS_JOBID".log"

SCRATCHDIR=/scratch_gs/$USER/$PBS_JOBID
mkdir -p "$SCRATCHDIR"
mkdir -p "$SCRATCHDIR/pre"

cp -r /gpfs/project/$USER/optimus_train_files/* $SCRATCHDIR/.

cd $PBS_O_WORKDIR

echo "$PBS_JOBID ($PBS_JOBNAME) @ `hostname` at `date` in "$RUNDIR" START" > $LOGFILE
echo "`date +"%d.%m.%Y-%T"`" >> $LOGFILE


module load Python/3.6.5

cp -r $PBS_O_WORKDIR/* $SCRATCHDIR/.
cd $SCRATCHDIR
rm $PBS_JOBNAME"."$PBS_JOBID".log"

echo >> $LOGFILE
qstat -f $PBS_JOBID >> $LOGFILE

python3 -m pip install --user --upgrade -i http://pypi.repo.test.hhu.de/simple/ --trusted-host pypi.repo.test.hhu.de pip

echo "load packages" >>  $LOGFILE
pip install --user -q -i http://pypi.repo.test.hhu.de/simple/ --trusted-host pypi.repo.test.hhu.de nltk 
pip install --user -q -i http://pypi.repo.test.hhu.de/simple/ --trusted-host pypi.repo.test.hhu.de pandas==1.1.5
pip install --user -q -i http://pypi.repo.test.hhu.de/simple/ --trusted-host pypi.repo.test.hhu.de tqdm>=4.41.0

echo "Preprocessing File" >> $LOGFILE

echo "starting training" >>  $LOGFILE

python preprocess_title.py >> $LOGFILE


cp $SCRATCHDIR/train_title.jsonl /gpfs/project/$USER/optimus_train_files/train_title.jsonl


echo "$PBS_JOBID ($PBS_JOBNAME) @ `hostname` at `date` in "$RUNDIR" END" >> $LOGFILE
echo "`date +"%d.%m.%Y-%T"`" >> $LOGFILE