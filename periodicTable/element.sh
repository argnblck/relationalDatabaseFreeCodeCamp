#!/bin/bash

# I'm from Russia, my English is still bad, so the rest of the comments will be in Russian.

PSQL="psql  --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# проверяем был, ли передан аргумент в скрипт
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
# проверяем передан ли атомный номер элемента в качестве аргумента
elif [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  # проверяем существует ли в базе переданный атомный номер элемента
  if [[ -z $ATOMIC_NUMBER ]]
  then
    # в базе не найден переданный атомный номер
    echo -e "I could not find that element in the database."
  else
    # в базе найден переданный атомный номер, выводим информацию об элементе.
    echo $($PSQL "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number = $1") | 
    while read NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MPC BAR BPC 
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPC celsius and a boiling point of $BPC celsius." | 
      sed -r 's/  */ /g'
    done
  fi
# проверяем передан ли символ элемента в качестве аргумента
elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
then
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$1'")
  # проверяем сушествует ли такой символ элемента в базе данных
  if [[ -z $SYMBOL ]]
  then
  # в базе не найден переданный символ элемента
  echo -e "I could not find that element in the database."
  else
  # в базе найден переданный символ элемента, выводим информацию об элементе.
  echo $($PSQL "SELECT atomic_number, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol = '$1'") |
  while read ATOMIC_NUMBER BAR NAME BAR TYPE BAR ATOMIC_MASS BAR MPC BAR BPC
  do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPC celsius and a boiling point of $BPC celsius." |
      sed -r 's/\( /\(/g'
    done
  fi
# проверяем передано ли имя элемента в качестве аргумента
elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
then
  NAME=$($PSQL "SELECT name FROM elements WHERE name = '$1'")
  # проверяем существует ли имя элемента в базе
  if [[ -z $NAME ]]
  then
  # в базе не найден переданное имя файла
    echo -e "I could not find that element in the database."
  else
  # в базе найден переданное имя элемента, выводим информацию об элементе.
  echo $($PSQL "SELECT atomic_number, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE name = '$1'") |
  while read ATOMIC_NUMBER BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MPC BAR BPC
  do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPC celsius and a boiling point of $BPC celsius." | 
      sed -r 's/  / /g'
    done
  fi
else
  # передан не корректный аргумент
  echo "I could not find that element in the database."
fi