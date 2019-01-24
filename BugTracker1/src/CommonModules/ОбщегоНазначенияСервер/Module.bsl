// Возвращает структуру, содержащую значения реквизитов прочитанные из информационной базы
// по ссылке на объект.
// 
//  Если доступа к одному из реквизитов нет, возникнет исключение прав доступа.
//  Если необходимо зачитать реквизит независимо от прав текущего пользователя,
//  то следует использовать предварительный переход в привилегированный режим.
// 
// Функция не предназначена для получения значений реквизитов пустых ссылок.
//
// Параметры:
//  Ссылка    - ЛюбаяСсылка - объект, значения реквизитов которого необходимо получить.
//
//  Реквизиты - Строка - имена реквизитов, перечисленные через запятую, в формате
//              требований к свойствам структуры.
//              Например, "Код, Наименование, Родитель".
//            - Структура, ФиксированнаяСтруктура - в качестве ключа передается
//              псевдоним поля для возвращаемой структуры с результатом, а в качестве
//              значения (опционально) фактическое имя поля в таблице.
//              Если значение не определено, то имя поля берется из ключа.
//            - Массив, ФиксированныйМассив - имена реквизитов в формате требований
//              к свойствам структуры.
//
// Возвращаемое значение:
//  Структура - содержит имена (ключи) и значения затребованных реквизитов.
//              Если строка затребованных реквизитов пуста, то возвращается пустая структура.
//              Если в качестве объекта передана пустая ссылка, то все реквизиты вернутся со значением Неопределено.
//
Функция ЗначенияРеквизитовОбъекта(Ссылка, Знач Реквизиты) Экспорт
	
	Если ТипЗнч(Реквизиты) = Тип("Строка") Тогда
		Если ПустаяСтрока(Реквизиты) Тогда
			Возврат Новый Структура;
		КонецЕсли;
		Реквизиты = СтрРазделить(Реквизиты, ",", Ложь);
	КонецЕсли;
	
	СтруктураРеквизитов = Новый Структура;
	Если ТипЗнч(Реквизиты) = Тип("Структура") Или ТипЗнч(Реквизиты) = Тип("ФиксированнаяСтруктура") Тогда
		СтруктураРеквизитов = Реквизиты;
	ИначеЕсли ТипЗнч(Реквизиты) = Тип("Массив") Или ТипЗнч(Реквизиты) = Тип("ФиксированныйМассив") Тогда
		Для Каждого Реквизит Из Реквизиты Цикл
			СтруктураРеквизитов.Вставить(СтрЗаменить(Реквизит, ".", ""), Реквизит);
		КонецЦикла;
	Иначе
		ВызватьИсключение ПодставитьПараметрыВСтроку(НСтр("ru = 'Неверный тип второго параметра Реквизиты: %1'"), Строка(ТипЗнч(Реквизиты)));
	КонецЕсли;
	
	ТекстПолей = "";
	Для Каждого КлючИЗначение Из СтруктураРеквизитов Цикл
		ИмяПоля   = ?(ЗначениеЗаполнено(КлючИЗначение.Значение),
		              СокрЛП(КлючИЗначение.Значение),
		              СокрЛП(КлючИЗначение.Ключ));
		
		Псевдоним = СокрЛП(КлючИЗначение.Ключ);
		
		ТекстПолей  = ТекстПолей + ?(ПустаяСтрока(ТекстПолей), "", ",") + "
		|	" + ИмяПоля + " КАК " + Псевдоним;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.Текст =
	"ВЫБРАТЬ
	|" + ТекстПолей + "
	|ИЗ
	|	" + Ссылка.Метаданные().ПолноеИмя() + " КАК ПсевдонимЗаданнойТаблицы
	|ГДЕ
	|	ПсевдонимЗаданнойТаблицы.Ссылка = &Ссылка
	|";
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	Результат = Новый Структура;
	Для Каждого КлючИЗначение Из СтруктураРеквизитов Цикл
		Результат.Вставить(КлючИЗначение.Ключ);
	КонецЦикла;
	ЗаполнитьЗначенияСвойств(Результат, Выборка);
	
	Возврат Результат;
	
КонецФункции

// Подставляет параметры в строку. Максимально возможное число параметров - 9.
// Параметры в строке задаются как %<номер параметра>. Нумерация параметров начинается с единицы.
//
// Параметры:
//  СтрокаПодстановки  - Строка - шаблон строки с параметрами (вхождениями вида "%ИмяПараметра");
//  Параметр<n>        - Строка - подставляемый параметр.
//
// Возвращаемое значение:
//  Строка   - текстовая строка с подставленными параметрами.
//
// Пример:
//  ПодставитьПараметрыВСтроку(НСтр("ru='%1 пошел в %2'"), "Вася", "Зоопарк") = "Вася пошел в Зоопарк".
//
// Примечание:
//  В случаях, когда число используемых параметров в строке совпадает с числом переданных для подстановки параметров,
//  рекомендуется использовать функцию платформы СтрШаблон.
Функция ПодставитьПараметрыВСтроку(Знач СтрокаПодстановки,
	Знач Параметр1, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено,
	Знач Параметр4 = Неопределено, Знач Параметр5 = Неопределено, Знач Параметр6 = Неопределено,
	Знач Параметр7 = Неопределено, Знач Параметр8 = Неопределено, Знач Параметр9 = Неопределено) Экспорт
	
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%1", Параметр1);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%2", Параметр2);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%3", Параметр3);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%4", Параметр4);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%5", Параметр5);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%6", Параметр6);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%7", Параметр7);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%8", Параметр8);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%9", Параметр9);
	
	Возврат СтрокаПодстановки;
КонецФункции

// Возвращает данные о подписках пользователей.
//
// Параметры:
//  Пользователь  - Справочник.Пользователи;
//  Ошибка        - Справочник.Ошибки;
//  
// Возвращаемое значение:
//  Результат запроса 
Функция ПолучитьДанныеПоПолучателямУведомлений(Пользователь,Ошибка,ДанныеПоОдномуПользователю = Истина) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПолучателиУведомлений.Пользователь КАК Пользователь		
		|ИЗ
		|	РегистрСведений.ПолучателиУведомлений КАК ПолучателиУведомлений
		|ГДЕ
		| &Пользователь	
		| &Ошибка
		| СГРУППИРОВАТЬ ПО
		|	ПолучателиУведомлений.Пользователь";
			
	Если ЗначениеЗаполнено(Пользователь) Тогда
		Если ДанныеПоОдномуПользователю Тогда
			ТестОтбора = "ПолучателиУведомлений.Пользователь = &Пользователь";
		Иначе
			ТестОтбора = "ПолучателиУведомлений.Пользователь <> &Пользователь";
		КонецЕсли;		
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"&Пользователь",ТестОтбора); 
		Запрос.УстановитьПараметр("Пользователь", Пользователь);
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"&Пользователь",""); 
	КонецЕсли;

	Если ЗначениеЗаполнено(Ошибка) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"&Ошибка"," И ПолучателиУведомлений.Ошибка = &Ошибка"); 
		Запрос.УстановитьПараметр("Ошибка", Ошибка);	
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"&Ошибка","");
	КонецЕсли;	
	
	Запрос.УстановитьПараметр("Пользователь", Пользователь);

	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса;
	
КонецФункции

Процедура ДобавитьУведомления(Пользователь,Ошибка,Дата,Комментарий,Получатели = Неопределено) Экспорт
	
	Если Получатели = Неопределено Тогда
		ДанныеВыборки = ПолучитьДанныеПоПолучателямУведомлений(Пользователь,Ошибка, Ложь);
	Иначе
		ДанныеВыборки = Получатели;
	КонецЕсли;
		
	Если НЕ ДанныеВыборки.Пустой() Тогда	
		
		ДанныеПоПолучателям = ДанныеВыборки.Выбрать();
		
		НаборЗаписейРегистра = РегистрыСведений.Уведомления.СоздатьНаборЗаписей();
		НаборЗаписейРегистра.Прочитать();
		
		Пока ДанныеПоПолучателям.Следующий() Цикл		
			ЗаписьНабора  = НаборЗаписейРегистра.Добавить();
			ЗаписьНабора.Период = Дата;
			ЗаписьНабора.Ошибка = Ошибка;
			ЗаписьНабора.Пользователь = ДанныеПоПолучателям.Пользователь;
			ЗаписьНабора.Комментарий  = Комментарий;
		КонецЦикла;	
		
		НаборЗаписейРегистра.Записать();
		
	КонецЕсли;

КонецПроцедуры	

Процедура ПронумероватьТекстКода(ТекстКода) Экспорт 
	
	ЧислоСтрок = СтрЧислоСтрок(ТекстКода);         
	НовыйТекст = "";

	ПерваяГраница = 110;
	ВтораяГраница = 160;   
	
	Для Сч = 1 По ЧислоСтрок Цикл
		СтрокаТекста = СокрП(СтрПолучитьСтроку(ТекстКода,Сч));	
		ДлинаСтроки  = СтрДлина(СтрокаТекста);
		
		Если ДлинаСтроки < ПерваяГраница Тогда
			ПозицияДляНомера = ПерваяГраница;
		ИначеЕсли ДлинаСтроки < ВтораяГраница Тогда
			ПозицияДляНомера = ВтораяГраница;
		Иначе
			ПозицияДляНомера = ДлинаСтроки; 
		КонецЕсли;	
			
		Пока СтрДлина(СтрокаТекста) < ПозицияДляНомера Цикл
			СтрокаТекста = СтрокаТекста + Символы.НПП;
		КонецЦикла;
		СтрокаТекста = СтрокаТекста + Символы.НПП + Символы.Таб + "//" + Формат(Сч, "ЧГ=0");
		
		НовыйТекст = НовыйТекст + СтрокаТекста + Символы.ПС;
	КонецЦикла;                             
	
	ТекстКода = НовыйТекст;	
	
КонецПроцедуры	
