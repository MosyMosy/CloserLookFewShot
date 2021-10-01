python ./train.py --dataset miniImagenet --model ResNet10 --method baseline++ --train_aug --n_shot 5
python ./save_features.py --dataset miniImagenet --model ResNet10 --method baseline++ --train_aug --n_shot 5
python ./test.py --dataset miniImagenet --model ResNet10 --method baseline++ --train_aug --n_shot 5
