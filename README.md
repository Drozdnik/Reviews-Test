Весь асинхронный код реализован с использованием async/await. Исправлена ошибка, связанная с некорректной загрузкой данных – количество ячеек превышало значение count, указанное в JSON.

Для загрузки изображений и аватаров разработаны отдельные сервисы, которые обращаются к networkingService, что соответствует принципам SOLID. Кэширование реализовано с помощью стандартного словаря, а верстка пока выполнена с использованием frame.

Решения по каждому заданию оформлены в отдельных pull request’ах, что позволяет просматривать изменения по отдельности. Мелкие исправления вносились непосредственно в ветку main, что допустимо для тестового проекта.

Все задания выполнены, за исключением реализации индикатора загрузки, поскольку не было однозначно определено, к какому процессу его привязать. Оптимальным решением было бы использование URLSessionDownloadDelegate, однако в проекте используется замоканная загрузка JSON с помощью sleep – вариант, который также можно было бы детализировать, но в рамках тестового проекта это не представлялось необходимым.

Основные изменения (ключевые pull request’ы):
1) Решена проблема зависания при прокрутке, был обернут async  метод получения данных  с помощью GCD в [пр](https://github.com/Drozdnik/Reviews-Test/pull/2)
2) Далее для большей читаемости кода GCD было переписано на [async await](https://github.com/Drozdnik/Reviews-Test/pull/3)
3) Далее привел layout к минимальному [варианту](https://github.com/Drozdnik/Reviews-Test/pull/5)
4) Были убраны [memory leak](https://github.com/Drozdnik/Reviews-Test/pull/15)
5) Добавил к ревью [фото](https://github.com/Drozdnik/Reviews-Test/pull/21)
   Вот что получилось по итогу https://private-user-images.githubusercontent.com/55313671/418101484-8eedd08b-7314-4cf8-9dfb-dcfc2f5036a7.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDA3NzI3MzUsIm5iZiI6MTc0MDc3MjQzNSwicGF0aCI6Ii81NTMxMzY3MS80MTgxMDE0ODQtOGVlZGQwOGItNzMxNC00Y2Y4LTlkZmItZGNmYzJmNTAzNmE3LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTAyMjglMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwMjI4VDE5NTM1NVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTliNWMwZTg3MWRjOGIwNzE5ZDk5NmNiY2EwZWJjNzkyYWQ1ODgxMzhhNzk5M2MxZTQwZDMzMzY0ZjcxYjQ4N2EmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.UNH1s1XfG1F8BzDAt6Sc9yElMBvKgtYplZxBGK9chmg
