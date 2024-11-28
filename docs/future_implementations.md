# Future implementation(s)

The following section aims to gather all those points I was not able to finish 
and that I think it would be great to implement some day.

1. I would definitely not use `astro` and go for writing my **own docker image
for Airflow** so as I can handle dependencies better and in order to know what
is going on behind the scenes.

2. I would also like to have **separate dependencies** for developing the code 
and code that is being pushed to production. There must be a way of defining
those with uv as we can do with pipenv.

3. I would be nice to have **CI/CD pipelines** that everytime we push code to 
the repository, they run pytest and the linters. Also, it would be great to
have a job that creates a Github Page out of our documentation as in Github 
Pages. I tried it, therefore the `mkdocs.yaml` but I think it does not work 
with private repositories.

4. I would like to add **more tests** as I already mentioned in the
`Setting up tests` in the _Modus Operandi_ documentation and maybe follow TDD
somehow next time.