#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#clean all tables, reset iterator
echo $($PSQL "TRUNCATE games,teams")
echo $($PSQL "SELECT setval('teams_team_id_seq',1)")
echo $($PSQL "SELECT setval('games_game_id_seq',1)")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  #skip 1st line
  if [[ $YEAR != 'year' ]]
  then
    #get winner team ID
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' ")
    #if not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
      RES_WIN=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ")
      if [[ $RES_WIN == "INSERT 0 1" ]]
      then
        echo Team uccesfully added, $WINNER
      fi 
    fi
    #get winning team id again
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' ")

    #get opp team id
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT' ")
    #if not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      RES_OPP=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ")
      if [[ $RES_OPP == "INSERT 0 1" ]]
      then
        echo Team succesfully added, $OPPPONENT
      fi 
    fi
    #get opp team id again
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT' ")
    
    #write to games
    RES=$($PSQL "INSERT INTO games(year,round,winner_goals,opponent_goals,winner_id,opponent_id) VALUES($YEAR,'$ROUND',$WIN_GOALS,$OPP_GOALS,$WINNER_TEAM_ID,$OPPONENT_TEAM_ID) ")
    #check status
    if [[ $RES == 'INSERT 0 1' ]]
    then
      echo Game added, $YEAR, $ROUND, $WINNER, $OPPONENT
    fi 
     
  fi
done 

pg_dump -cC --inserts -U freecodecamp worldcup > worldcup.sql