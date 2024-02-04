# U Do Note for developers

## Adding a new feature

- Make a new branch first and check it out
  
    ```txt
    git checkout -b <branch-name>
    ```

- Add another folder under **features** and name it as the new feature, for instance, **reservation**.

- Add these folders under your new feature folder.

    > 💡 If you are not going to use the folder, just leave a `.gitkeep` file inside.

    ```txt
    📦reservation
    ┣ 📂data
    ┃ ┣ 📂datasources
    ┃ ┣ 📂models
    ┃ ┗ 📂repositories
    ┣ 📂domain
    ┃ ┣ 📂entities
    ┃ ┣ 📂repositories
    ┃ ┗ 📂usecases
    ┗ 📂presentation
    ┃ ┣ 📂pages
    ┃ ┣ 📂providers
    ┃ ┗ 📂widgets
    ```

## Extra Notes

1. file names must be in **snake_case.**
2. You can start adding your needed entities in the domain layer.
3. Then define the feature's methods in the domain layer's repositories just follow the name as `<FeatureName>Repository`.
4. After defining the methods, you can start to work on the use cases, every use case must have a `call` method.
5. And should be composed of the repository (composition).
6. Repeat **4** until you added all of the use cases you need.
7. Next is work on the data layer, make the models.
8. The properties of the models is the same as the entity but it haves a method for converting a model from entity or vice versa.
9. Add hive annotations to your models.
10. After adding hive annotations, build the packages `dart run`
11. Setup data sources
12. Implement the repositories in the data layer using the data sources (using composition)

- ⚡ Start coding! ⚡$$
