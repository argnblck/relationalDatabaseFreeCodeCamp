#!/bin/bash

# I'm from Russia, my English is still bad, so the rest of the comments will be in Russian.

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# генерируем случайно число от 0 до 1000
SECRET_NUMBER=$(( $RANDOM%1000  ))
# переменная количества попыток пользователя
NUMBER_OF_GUESSES=0
# функция проверки ввода пользователя
CHECK_USER_NUMBER() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  read USER_NUMBER

  # проверяем ввел ли пользователь число
  if [[ ! $USER_NUMBER =~ ^[0-9]+$ ]]
  then
  CHECK_USER_NUMBER "That is not an integer, guess again:"
  # проверяем число пользователя больше загаданого числа
  elif [[ $USER_NUMBER > $SECRET_NUMBER ]]
  then
  # увеличиваем количество попыток пользователя на 1
  (( NUMBER_OF_GUESSES ++ ))
  CHECK_USER_NUMBER "It's lower than that, guess again:"
  # проверяем число пользователя меньше загаданого числа
  elif [[ $USER_NUMBER < $SECRET_NUMBER ]]
  then
  # увеличиваем количество попыток пользователя на 1
  (( NUMBER_OF_GUESSES ++ ))
  CHECK_USER_NUMBER "It's higher than that, guess again:"
  # число пользователя совпадает с загаданым числом
  elif [[ $USER_NUMBER == $SECRET_NUMBER ]]
  then
  # увеличиваем количество попыток пользователя на 1
  (( NUMBER_OF_GUESSES ++ ))
  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi
}

echo "Enter your username:"
read USERNAME

# проверяем играл ли пользователь ранее, есть ли его имя в БД
if [[ $USERNAME == $($PSQL "SELECT username FROM users WHERE username = '$USERNAME'") ]]
then
  # если имя пользователя есть в БД, выводим его имя, количество попыток и его лучший результат
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  CHECK_USER_NUMBER "Guess the secret number between 1 and 1000:"
  # увеличиваем количество игр на 1
  (( GAMES_PLAYED ++ ))
  # обновляем данные в базе
  if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
  then
    # если количество попыток пользователя меньше его лучше результата, в БД обновляем количество игр и лучший результат
    UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
  else
    # если количество попыток пользователя больше его лучше результата, в БД обновляем только количество игр
    UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username = '$USERNAME'")
  fi
else
  # если пользователь ранее не играл, после игры, добавляем в БД его имя, количество сыгранных игр 1 и его результат игры 
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  CHECK_USER_NUMBER "Guess the secret number between 1 and 1000:"
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES)")
fi
