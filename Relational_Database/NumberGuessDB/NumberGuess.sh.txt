#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

GENERATE_RANDNUM(){
  RANDNUM=$(( $RANDOM % 1000 + 1 ))
  #echo $RANDNUM
}

GUESS_NUM(){
  #increment num of guesses
  NUM_OF_GUESSES=$(($NUM_OF_GUESSES+1))
  #read guess inp
  echo "Guess the secret number between 1 and 1000:"
  read GUESS_INP
  #check if inp is number
  if [[ $GUESS_INP =~ ^[0-9]+$ ]]
    then
    #check if guess is right
    if [[ $GUESS_INP < $RANDNUM ]]
    then
      echo "It's higher than that, guess again:"
      GUESS_NUM
    elif [[ $GUESS_INP > $RANDNUM ]]
    then
      echo "It's lower than that, guess again:"
      GUESS_NUM
    else
      echo "You guessed it in $NUM_OF_GUESSES tries. The secret number was $RANDNUM. Nice job!"
    fi
  else
    echo "That is not an integer, guess again:"
    GUESS_NUM
  fi
}

#MAIN FUNCTION

#read name
echo "Enter your username:"
read USERNAME
#check in db if name is available
CHECK_NAME_RES=$($PSQL "SELECT games_played,best_game FROM users WHERE username='$USERNAME'; ")
#if name not available
if [[ -z $CHECK_NAME_RES ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  #add user to db
  ADD_USER_RES=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',1,1000)")
#if name available
else
  #reshape output
  CHECK_NAME_RES=$(echo $CHECK_NAME_RES | sed 's/|/ /')
  #query user info
  echo $CHECK_NAME_RES | while read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
  done
fi
#Generate random number
GENERATE_RANDNUM
#initialize # of attempts
NUM_OF_GUESSES=0
#let user guess
GUESS_NUM

#get user info again
GET_INFO_RES=$($PSQL "SELECT games_played,best_game FROM users WHERE username='$USERNAME'; ")
#reshape output
GET_INFO_RES=$(echo $GET_INFO_RES | sed 's/|/ /')
#query user info
echo $GET_INFO_RES | while read GAMES_PLAYED BEST_GAME
do
  #check if best game should be updated
  UPDATE=$(( $NUM_OF_GUESSES < $BEST_GAME ))
  echo $UPDATE
  if [[ $UPDATE = 1 ]]
  then
    BEST_GAME=$NUM_OF_GUESSES
  fi
  #store data to db
  echo $NUM_OF_GUESSES, $BEST_GAME
  UPDATE_RES=$($PSQL "UPDATE users SET games_played = $(($GAMES_PLAYED+1)), best_game = $BEST_GAME WHERE username = '$USERNAME';")
done

