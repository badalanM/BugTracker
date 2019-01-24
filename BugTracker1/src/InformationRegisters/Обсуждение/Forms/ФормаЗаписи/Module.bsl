
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.ЗначенияЗаполнения.Свойство("Ошибка") Тогда
		Запись.Ошибка = Параметры.ЗначенияЗаполнения.Ошибка;
	КонецЕсли;
	
	Если не ЗначениеЗаполнено(Запись.Ошибка) Тогда // иначе подставляется текущий пользователь вместо автора в имеющуюся запись
		Запись.Пользователь = Справочники.Пользователи.УстановитьОтветственногоПоПользователюИБ();
	КонецЕсли;
	
КонецПроцедуры
