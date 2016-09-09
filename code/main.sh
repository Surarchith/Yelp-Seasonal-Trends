echo  "Welcome"

echo  "Please enter your net id"
read netid
echo  "Sending the file 1 to hadoop"
scp business.json $netid@cs6360.utdallas.edu:

echo  "Sending the file 2 to hadoop"
scp checkin.json $netid@cs6360.utdallas.edu:

echo  "Sending the file 3 to hadoop"
scp user.json $netid@cs6360.utdallas.edu:

echo  "Sending the file 4 to hadoop"
scp tip.json $netid@cs6360.utdallas.edu:

echo  "Sending the file 4 to hadoop"
scp review.json $netid@cs6360.utdallas.edu:

echo "\n Done"
echo "\n All files hae been sucessfuly uploaded into Cluster"

echo "Starting the second script"
ssh $netid@cs6360.utdallas.edu 'bash -s' < cluster.sh

