
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Отбор.Свойство("Пользователь") Тогда
		ЭтотОбъект.АвтоЗаголовок = Ложь;
		ЭтотОбъект.Заголовок = "Мои обсуждения";	
	КонецЕсли;
КонецПроцедуры

