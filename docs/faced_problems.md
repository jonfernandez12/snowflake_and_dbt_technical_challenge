# Faced problems

This section aims to gather the most relevant problems I faced during the 
development of the technical challenge. However, I believe most of them were 
already described in the _Modus Operandi_ documentation.

## Deploying Airflow
Deploying Airflow is a bit of a hustle having in mind that you need at least 
three containers running as services (scheduler, webserver and executor) and 
another two containers for databases (airflow and celery). I did not like the
approach I followed with _astro_ since I felt handcuffed. I am pretty sure there 
some predefined docker images there I can just copy&paste to build my own 
image.

## Raw data bulking
When developing locally, it would be great to have access to some kind of 
cloud storage to be able to replicate an end-to-end system behaviour without 
the need of using big platforms that yes, have free tiers but also ask for you 
card number.

## Requirement manager
I really like uv python package manager, and it is very fast indeed, however, 
I felt a bit lost and frustrated when trying to dump or compile the packages 
in uv to a `requirements.txt` file and making a 3rd party docker image not 
explode while trying to read these requirements.txt file.