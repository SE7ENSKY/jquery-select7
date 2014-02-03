jquery-select7
==============

Select2-like wheel reinvent. Project status is incubating.

## Example
[see example](http://se7ensky.github.io/jquery-select7/example.html)

## Unfiltered
Якщо є html select, наприклад
select.select7
	option(value="rating", selected) по рейтингу
	option(value="price") по цене
	option(value="any") просто так

то перетворити його в кастомний селект можна за допомогою $("селектор до оригінального select").select7()

Повернути стандартний HTML селект можна за допомогою $("селектор до оригінального select").select7("destroy")

Програмно відкрити, закрити, відкрити/закрити .select7("open"), .select7("close"), .select7("toggle")

Ініціалізовувати select7 через $("...").trigger("reinitSelect7")
це потрібно для того, щоб ініціалізовувати його з стандартними налаштуваннями цього проекту, хоча там поки що немає таких налаштувань :) select2 точно таким же чином ініціалізовується .trigger("reinitSelect2")

Подія change виникає в оригінального select, тобто можна писати щось типу
$("селектор до оригінального select").change(function(){
  console.log($(this).val())
})

Якщо потрібно встановити якесь значення, то це $("...").val(...).trigger("change")
