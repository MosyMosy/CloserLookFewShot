python ./train.py --dataset miniImagenet --model ResNet10 --method baseline++ --train_aug --n_shot 1
python ./save_features.py --dataset miniImagenet --model ResNet10 --method baseline++ --train_aug --n_shot 1
python ./test.py --dataset miniImagenet --model ResNet10 --method baseline++ --train_aug --n_shot 1
