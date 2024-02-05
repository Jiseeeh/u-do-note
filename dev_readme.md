# U Do Note for developers

## Adding a new feature

- Make a new branch first and check it out
  
    ```txt
    git checkout -b <branch-name>
    ```

- Add another folder under **features** and name it as the new feature, for instance, **reservation**.

- Add these folders under your new feature folder.

    > 💡 If you are not going to use the folder, just leave a `.gitkeep` file inside if you think you might need it in the future.
    >
    >💡file names must be in **snake_case.**

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


## Next Steps

1. You can start adding your needed entities in the domain layer.
2. Then define the feature's methods in the domain layer's repositories just follow the name as `<FeatureName>Repository`.
3. After defining the methods, you can start to work on the use cases, every use case must have a `call` method.
4. And should be composed of the repository (composition).
5. Repeat **4** until you added all of the use cases you need.
6. Next is work on the data layer, make the models.
7. The properties of the models is the same as the entity but it haves a method for converting a model from entity or vice versa.
8. Add hive annotations to your models.
9. After adding hive annotations, build the packages `dart run build_runner build`
10. Setup data sources
11. Implement the repositories in the data layer using the data sources (using composition)
12. Add providers for every use case, and then run `dart run build_runner build` to generate the part files
13. Next is start working with the ui, place them under `pages/` and should be named as `<page_name>_screen.dart`
14. Add that route under in `app_route.dart` and then build again `dart run build_runner build`

> 💡 If you do not want to keep building, use watch instead `dart run build_runner watch`

## Extra information
