## Features

**KinopoiskLoginAndSearch** 
- login and password using KeyChain and UserPreferences - wrapper above user defaults
- fetches data from internet, concurrency for fetching films and their stills, multithreading managing with group
- **custom cacheManager based on saving images to FileManager and paths [webToDownload : localSavedToFileManagerTemp]**
- **saves paths to NSPersistentContainer (CoreData)**
- custom Button, you can tap at title and pick year for filter films by it
- custom navigationController
- sorting and searching
- details screen with cover image and collection of stills, they(cover and stills) comes in different responses
- showing alerts

**Stack**
- CLEAN, dependencies injection using constructor and properties
- abstractions 
- CoreData, Security (Keychain)
- DifferenceKit for optimizing updates
- SnapKit, no storyboard
- Reusable
- ActivityIndicatorView, SOLID, DRY

<img src="https://github.com/user-attachments/assets/2a1ce6c9-4d20-4bbe-9be9-5d954a3d625a" width="295">   <img width="295" alt="Снимок экрана 2024-09-19 в 01 43 59" src="https://github.com/user-attachments/assets/4b8f17cb-ca49-4a1e-9869-da96a4d444f3">    <img width="295" alt="Снимок экрана 2024-09-19 в 01 44 23" src="https://github.com/user-attachments/assets/9bdcce3b-e9a6-41c1-a295-b38d1ca2e6ef">

- Загружает из интернета список фильмов
- В каждом фильме есть ссылка на скачивание картинки из сети
- Для скачивания картинок реализован кастомный CacheManager на основе CoreData и FileManager (храним словарь: ключ - ссылка на скачивание картинки из интеренета, значение - путь до data, которую сохранили в FileManager)
- Есть скелетон или placeholder image пока не загрузились аватарки фильмов для таблицы фильмов и cover для детального экрана
- Алерты, Сортировка, Поиск, Кастомная кнопка с выбором года и картинкой в ней
- Кастомный навигационный контроллер
- Переход в web по ссылке
