
&НаСервере
Процедура РезультатОбработкаРасшифровкиНаСервере(Расшифровка,Сайт)

	Данные = ПолучитьИзВременногоХранилища(ДанныеРасшифровки);
	ЭлементыРасшифровки = Данные.Элементы.Получить(Расшифровка);
	Поля = ЭлементыРасшифровки.ПолучитьПоля(); 
	
	Для Каждого ПоляРасшифровки Из Поля Цикл
		Если ПоляРасшифровки.Поле = "СсылкаJIRA" И ЗначениеЗаполнено(ПоляРасшифровки.Значение) Тогда 
			Сайт = ПоляРасшифровки.Значение;
			Прервать;
		КонецЕсли;	
	КонецЦикла;		
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка, ДополнительныеПараметры)
	
	Сайт = "";
	Если ТипЗнч(Расшифровка) = Тип("Строка") И Найти(НРег(Расшифровка),"http") > 0 Тогда
		Сайт = Расшифровка;	
	ИначеЕсли ТипЗнч(Расшифровка) = Тип("ИдентификаторРасшифровкиКомпоновкиДанных") Тогда
		РезультатОбработкаРасшифровкиНаСервере(Расшифровка,Сайт);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Сайт) Тогда	
		ЗапуститьПриложение(Сайт);
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры