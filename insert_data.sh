#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate tables 
echo "$($PSQL "TRUNCATE games, teams RESTART IDENTITY")"

# Read games.csv and process each row
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS 
do 
  # Skip header row 
  if [[ $YEAR != year ]]
  then 
    # Insert winner team into the teams table 
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    if [[ -z $WINNER_ID ]]
    then 
      INSERT_WINNER_RESULTS="$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")"
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then 
        echo "Inserted into teams: $WINNER"
      fi
      WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    fi

    # Insert opponent team into the teams table 
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    if [[ -z $OPPONENT_ID ]]
    then 
      INSERT_OPPONENT_RESULT="$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")"
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1 " ]]
      then 
        echo "Inserted into teams: $OPPONENT"
      fi
      OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    fi

    # Insert game into the games table 
    INSERT_GAME_RESULTS="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
    if [[ $INSERT_GAME_RESULTS == "INSERT 0 1" ]]
    then 
      echo "Inserted into games: $YEAR $ROUND - $WINNER vs $OPPONENT"
    fi
  fi
done
