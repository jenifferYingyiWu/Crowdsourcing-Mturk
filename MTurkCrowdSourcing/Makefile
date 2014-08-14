compile:
	javac -d . -cp ".:external_jars/*" MTurkCrowdSourcing

run:
	java -cp "external_jars/*:." mturkcrowdsourcing.MTurkCrowdSourcing face10.question face10.details "face orientation detection" "determine the orientation of the face" 1 0.01 0.4 0 300 7200 3600 "face, orientation, picture, categorization, survey" 5000 PrimaryKey orientation 2,3,4,5,6 3,6 csHistory
