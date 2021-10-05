#!/bin/bash
#SBATCH --mail-user=Moslem.Yazdanpanah@gmail.com
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=baseline_1shot_na
#SBATCH --output=%x-%j.out
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --ntasks-per-node=32
#SBATCH --mem=127000M
#SBATCH --time=3-00:00
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

for method in "maml" "relationnet" "matchingnet" "protonet"  "baseline" "baseline++"
do
    for backbone in "Conv4_na" "Conv6_na" "ResNet10_na" "ResNet18_na" "ResNet34_na" 
    do
        cd $SLURM_TMPDIR
        cd CloserLookFewShot
        
        python ./train.py --dataset miniImagenet --model $backbone --method $method --train_aug --n_shot 5 --gpu 0 &
        python ./train.py --dataset CUB --model $backbone --method $method --train_aug --n_shot 5 --gpu 1 &
        python ./train.py --dataset cross --model $backbone --method $method --train_aug --n_shot 5 --gpu 2 &
        python ./train.py --dataset cross_char --model $backbone --method $method --train_aug --n_shot 5 --gpu 3 &
        wait
        python ./save_features.py --dataset miniImagenet --model $backbone --method $method --train_aug --n_shot 5 --gpu 0 &
        python ./save_features.py --dataset CUB --model $backbone --method $method --train_aug --n_shot 5 --gpu 1 &
        python ./save_features.py --dataset cross --model $backbone --method $method --train_aug --n_shot 5 --gpu 2 &
        python ./save_features.py --dataset cross_char --model $backbone --method $method --train_aug --n_shot 5 --gpu 3 &
        wait
        python ./test.py --dataset miniImagenet --model $backbone --method $method --train_aug --n_shot 5 --gpu 0 &
        python ./test.py --dataset CUB --model $backbone --method $method --train_aug --n_shot 5 --gpu 1 &
        python ./test.py --dataset cross --model $backbone --method $method --train_aug --n_shot 5 --gpu 2 &
        python ./test.py --dataset cross_char --model $backbone --method $method --train_aug --n_shot 5 --gpu 3 &
        wait
        echo "-----------------------------------<End of run the $method $backbone>---------------------------------"
        date +"%T"
        echo "--------------------------------------<backup the result>-----------------------------------"
        date +"%T"
        cd $SLURM_TMPDIR
        cp -r $SLURM_TMPDIR/CloserLookFewShot/record/ ~/scratch/CloserLookFewShot/
    done
done

echo finish