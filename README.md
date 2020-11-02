# COP 5615 - Project 2
The goal of this project is to implement convergence of gossip algorithm

## Group Info
  - Shashi Prakash,  UFID: 5891-2989
  - Shivam Agarwal,  UFID: 0319-3956

##What is working 
- Convergence of all topologies except line for both algorithms.
- BONUS: Convergence of Gossip algorithm under varying failure rates

##Largest working problems 
NOTE: The logs were removed while measuring largest working problems 
###Gossip
- Full: 20,000 nodes;  650 seconds
- 3D: 20,000; 820 seconds
- Random 2D: 20,000 nodes; 660 seconds
- Honeycomb: 20,000 nodes; 1230 seconds
- Random Honeycomb: 20,000 nodes; 1130 seconds

###Push-sum
- Full: 4,000; 614395 seconds
- 3D: 7,000; 325 seconds
- Random 2D: 3,000; 137 seconds
- Honeycomb: 5,000; 367 seconds
- Random Honeycomb: 5,000; 530 seconds



