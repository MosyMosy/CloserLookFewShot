#!/bin/bash
#SBATCH --mail-user=Moslem.Yazdanpanah@gmail.com
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=1_shot
#SBATCH --output=%x-%j.out
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --ntasks-per-node=32
#SBATCH --mem=127000M
#SBATCH --time=0-08:00
#SBATCH --account=rrg-ebrahimi

nvidia-smi

source ~/ENV/bin/activate

echo "------------------------------------< Data preparation>----------------------------------"
echo "Copying the source code"
date +"%T"
cd $SLURM_TMPDIR
cp -r ~/scratch/CloserLookFewShot .

echo "Copying the ImageNet"
date +"%T"
cd CloserLookFewShot/filelists/miniImagenet
cp ~/scratch/imagenet_object_localization_patched2019.tar.gz .

echo "creating data directories"
date +"%T"

cd ..
cd CUB
bash download_CUB.sh

cd ..
cd omniglot
bash download_omniglot.sh

cd ..
cd emnist
bash download_emnist.sh

cd ..
cd miniImagenet
bash download_miniImagenet.sh

echo "----------------------------------< End of data preparation>--------------------------------"
date +"%T"
echo "--------------------------------------------------------------------------------------------"

echo "---------------------------------------<Run the program>------------------------------------"
date +"%T"
cd $SLURM_TMPDIR
cd CloserLookFewShot

python ./train.py --dataset miniImagenet --model ResNet10 --method baseline++ --train_aug --n_shot 1
python ./save_features.py --dataset miniImagenet --model ResNet10 --method baseline++ --train_aug --n_shot 1
python ./test.py --dataset miniImagenet --model ResNet10 --method baseline++ --train_aug --n_shot 1

echo "-----------------------------------<End of run the program>---------------------------------"
date +"%T"
echo "--------------------------------------<backup the result>-----------------------------------"
date +"%T"
cd $SLURM_TMPDIR
cp -r $SLURM_TMPDIR/CloserLookFewShot/record/ ~/scratch/CloserLookFewShot/
