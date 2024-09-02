# Project
This repo works to spatially represent data collected from the STEP Learning Collaborative project, such that we can monitor outreach to the community in early psychosis. 

# Data
Patient data is currently drawn from the Yale RedCap system. This is protected information - please contact me for further information. 

Census and population related data used to i. create/draw the maps, and 2. as data for the contents of the plots themselves. The specific files used for this analysis are available here. 

Outreach response - several maps look at trying to measure how well the LC is managing to reach individuals in the population, given the need in that specific zipcode. Here the plots use the Social Vulnerability Index. SVI ranks the tracts on 16 social factors, including unemployment, racial and ethnic minority status, and disability, and further groups them into four related themes. Thus, each tract receives a ranking for each Census variable and for each of the four themes as well as an overall ranking.

# Running the scripts
An renv has been created such that when you open this directory on your local device, the environment required for thie repo to work should be automatically loaded.  

Scripts should be run in numerical order. Scripts 1-5 are sequentially linked - whereby each script produces an intermediary output that is required by the next script. These are needed to create and draw the maps of CT. The remaining scripts produce maps of various kinds. 