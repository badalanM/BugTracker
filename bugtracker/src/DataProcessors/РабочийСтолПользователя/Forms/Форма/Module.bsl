
&НаКлиенте
Процедура СписокУведомленийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ТекущиеДанные = Элементы.СписокУведомлений.ТекущиеДанные;
	Если ТекущиеДанные <> Неопределено Тогда  
		ОткрытьФорму("Справочник.Ошибки.ФормаОбъекта", Новый Структура("Ключ", ТекущиеДанные.Ошибка), ТекущиеДанные.Ошибка); 
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)	
	СписокУведомлений.Параметры.УстановитьЗначениеПараметра("Пользователь", Справочники.Пользователи.УстановитьОтветственногоПоПользователюИБ());
КонецПроцедуры

