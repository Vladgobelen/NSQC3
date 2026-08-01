-- ============================================================
-- COURSE DATA: MODULES 1-6
-- ============================================================

ns_llua = ns_llua or {}
ns_llua['lua'] = ns_llua['lua'] or {}

ns_llua['lua'][1] = {
    type = "info",
    title = "Введение в Lua",
    content = [=[
<h>Введение в Lua</h>
Lua — это легковесный, динамический язык программирования, основанный на таблицах. Он поддерживает разные стили программирования: императивный, объектно-ориентированный (через таблицы и метатаблицы) и функциональный. Имеет всего несколько типов данных, а основной структурой данных является таблица.

Чаще всего его используют как встраиваемый скриптовый язык в играх и приложениях, но также он работает и самостоятельно — например, в консольных утилитах или веб-серверах.

<h>Переменные и область видимости</h>
В Lua 5.1 переменные могут быть глобальными или локальными.

<t>Локальные переменные</t> — объявляются с ключевым словом <k>local</k>, доступны только в пределах своего блока. Использование локальных переменных делает код быстрее.

<t>Глобальные переменные</t> — объявляются без <k>local</k> и доступны отовсюду, но их использование считается плохой практикой.

<t>Примеры кода:</t>
<code>
<cm>-- Объявление локальной переменной</cm>
<kw>local</kw> userName <op>=</op> <st>'Высшая'</st>

<cm>-- Объявление глобальной переменной</cm>
userName <op>=</op> <st>"Шеф"</st>

<cm>-- Константы принято писать заглавными</cm>
<kw>local</kw> MAX_USERS <op>=</op> <nu>100</nu>
</code>

<w>Примечание:</w> По соглашению, константы (значения, которые не должны меняться) записывают в ВЕРХНЕМ_РЕГИСТРЕ. Хотя язык не запрещает их изменять, хорошей практикой считается этого не делать.
]=],
}

ns_llua['lua'][2] = {
    type = "info",
    title = "Комментарии в Lua",
    content = [=[
<h>Комментарии в Lua</h>
Комментарии — это текст в коде, который игнорируется интерпретатором. Они нужны для пояснения логики, временного отключения кода или оставления заметок для других разработчиков.

<h>Однострочные комментарии</h>
Однострочный комментарий начинается с двух дефисов <c>--</c>. Всё, что находится после них до конца строки, игнорируется при выполнении.

<t>Примеры:</t>
<code>
<cm>-- Это комментарий, он не выполнится</cm>
<kw>local</kw> x <op>=</op> <nu>10</nu>  <cm>-- А это комментарий после кода</cm>
</code>

<h>Многострочные комментарии</h>
Для комментирования больших блоков кода используются многострочные комментарии. Они начинаются с <c>--[[</c> и заканчиваются <c>]]</c>. Всё, что находится между ними, будет проигнорировано.

<t>Пример:</t>
<code>
<cm>--[[
Этот код не выполнится:
local a = 5
local b = 10
print(a + b)
]]</cm>

<cm>-- А это уже выполнится</cm>
<kw>print</kw><op>(</op><st>"Привет, мир!"</st><op>)</op>
</code>
]=],
}

ns_llua['lua'][3] = {
    type = "info",
    title = "Команда /run",
    content = [=[
<h>Команда /run</h>

<t>Назначение:</t> выполнение Lua-кода прямо в игре без создания аддона.

<t>Синтаксис:</t>
<code>
<kw>/run</kw> код
</code>

<t>Примеры для практики:</t>
<code>
<cm>-- Вывод сообщения в чат</cm>
<kw>/run</kw> <kw>print</kw><op>(</op><st>"Hello, World!"</st><op>)</op>

<cm>-- Математические операции</cm>
<kw>/run</kw> <kw>print</kw><op>(</op><nu>2</nu> <op>+</op> <nu>2</nu> <op>*</op> <nu>3</nu><op>)</op>

<cm>-- Создание глобальной переменной</cm>
<kw>/run</kw> myVar <op>=</op> <st>"Привет"</st>

<cm>-- Использование созданной переменной</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>myVar<op>)</op>

<cm>-- Несколько команд в одной строке</cm>
<kw>/run</kw> <kw>local</kw> a<op>=</op><nu>5</nu><op>;</op> <kw>local</kw> b<op>=</op><nu>10</nu><op>;</op> <kw>print</kw><op>(</op>a<op>+</op>b<op>)</op>
</code>

<h>Локальные и глобальные переменные в /run</h>

<t>Важное различие:</t>
<code>
<cm>-- Команда 1: создаём локальную переменную</cm>
<kw>/run</kw> <kw>local</kw> x <op>=</op> <nu>10</nu>

<cm>-- Команда 2: пытаемся вывести x</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>x<op>)</op>  <cm>-- nil! Переменная не существует</cm>
</code>

<t>Почему x равен nil?</t> Потому что <k>local</k> создаёт переменную только внутри текущего блока. Когда команда завершается — переменная уничтожается.

<code>
<cm>-- Команда 1: создаём глобальную переменную</cm>
<kw>/run</kw> y <op>=</op> <nu>20</nu>

<cm>-- Команда 2: выводим y</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>y<op>)</op>  <cm>-- 20! Переменная доступна</cm>
</code>

<t>Почему y доступен?</t> Без <k>local</k> переменная попадает в глобальную область и живёт до перезагрузки интерфейса.

<w>Запомни:</w> Локальные переменные живут только внутри одной команды /run. Глобальные — сохраняются между командами.

<h>Команда /dump</h>

<t>Назначение:</t> улучшенный вывод для отладки. Показывает значение и его структуру.

<t>Отличия от print:</t>
- <k>/dump</k> показывает содержимое таблиц и функций
- Удобен для проверки переменных
- Выводит данные в структурированном виде

<t>Примеры вывода:</t>
<code>
<cm>-- dump с таблицей — показывает структуру</cm>
<kw>/dump</kw> <op>{</op><st>"меч"</st><op>,</op> <st>"щит"</st><op>}</op>

<cm>Dump: value={</cm>
<cm>[1]="меч",</cm>
<cm>[2]="щит"</cm>
<cm>}</cm>
</code>

<h>Функции WoW API</h>
В игре доступно множество встроенных функций:

<code>
<cm>-- Показать имя персонажа</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>UnitName<op>(</op><st>"player"</st><op>)</op><op>)</op>

<cm>-- Показать текущее здоровье</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>UnitHealth<op>(</op><st>"player"</st><op>)</op><op>)</op>

<cm>-- Показать координаты</cm>
<kw>/run</kw> <kw>local</kw> x<op>,</op>y <op>=</op> GetPlayerMapPosition<op>(</op><st>"player"</st><op>)</op><op>;</op> <kw>print</kw><op>(</op>x<op>)</op><op>;</op> <kw>print</kw><op>(</op>y<op>)</op>
</code>

<t>Советы:</t>
- Стрелки вверх/вниз — история команд
- Несколько команд разделяйте <k>;</k> (точка с запятой)

<w>Важно:</w> Глобальные переменные сохраняются до перезагрузки интерфейса (/reload). Это позволяет использовать их для экспериментов и тестов!
]=],
}

ns_llua['lua'][4] = {
    type = "info",
    title = "Типы данных в Lua",
    content = [=[
<h>Типы данных в Lua</h>
Lua имеет 8 основных типов данных. Понимание типов — основа работы с переменными.

<h>nil — отсутствие значения</h>
<t>nil</t> означает "ничего". Единственное значение типа nil.

<code>
<kw>local</kw> empty <op>=</op> <kw>nil</kw>
<kw>local</kw> another  <cm>-- без значения будет nil</cm>
</code>

<h>boolean — логический тип</h>
Два значения: <k>true</k> (истина) и <k>false</k> (ложь).

<code>
<kw>local</kw> isAlive <op>=</op> <kw>true</kw>
<kw>local</kw> isDead <op>=</op> <kw>false</kw>
</code>

<w>Внимание:</w> Только <k>false</k> и <k>nil</k> считаются ложными. 0 и "" — это true!

<h>number — числа (БЕЗ кавычек!)</h>
<t> Золотое правило:</t> Числа пишутся <w>БЕЗ</w> кавычек.

<code>
<kw>local</kw> integer <op>=</op> <nu>42</nu>
<kw>local</kw> float <op>=</op> <nu>3.14</nu>
<kw>local</kw> negative <op>=</op> <op>-</op><nu>10</nu>
</code>

<h>string — строки (В КАВЫЧКАХ!)</h>
<t>Золотое правило:</t> Строки пишутся <w>СТРОГО В</w> кавычках.

<code>
<kw>local</kw> single <op>=</op> <st>'Привет'</st>
<kw>local</kw> double <op>=</op> <st>"Мир"</st>
</code>

<h>Число vs Строка</h>
Даже если <k>print</k> выводит их одинаково, для Lua это РАЗНЫЕ вещи:

<code>
<cm>-- ЧИСЛО 777</cm>
<kw>local</kw> num <op>=</op> <nu>777</nu>
<kw>print</kw><op>(</op>num<op>)</op>           <cm>-- 777</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op>num<op>)</op><op>)</op>      <cm>-- "number"</cm>

<cm>-- СТРОКА "777"</cm>
<kw>local</kw> str <op>=</op> <st>"777"</st>
<kw>print</kw><op>(</op>str<op>)</op>           <cm>-- 777</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op>str<op>)</op><op>)</op>      <cm>-- "string"</cm>
</code>

<h>Фишка Lua: Автоприведение</h>
Lua умная — сама превращает строки в числа и наоборот, смотря по оператору:

<code>
<cm>-- Сложение: строка -> число</cm>
<kw>print</kw><op>(</op><st>"777"</st> <op>+</op> <nu>1</nu><op>)</op>    <cm>-- 778 верно</cm>

<cm>-- Конкатенация: число -> строка</cm>
<kw>print</kw><op>(</op><nu>777</nu> <op>..</op> <nu>1</nu><op>)</op>     <cm>-- "7771" верно</cm>
</code>

<h>Когда будет ОШИБКА?</h>
Автоприведение работает только если строка похожа на число:

<code>
<kw>print</kw><op>(</op><st>"5"</st> <op>+</op> <nu>10</nu><op>)</op>      <cm>-- 15 верно</cm>
<kw>print</kw><op>(</op><st>"Привет"</st> <op>+</op> <nu>10</nu><op>)</op>  <cm>-- ОШИБКА!</cm>
</code>

<h>table — таблицы</h>
Самый мощный тип данных. И массив, и словарь одновременно.

<code>
<cm>-- Как массив</cm>
<kw>local</kw> items <op>=</op> <op>{</op><st>"меч"</st><op>,</op> <st>"щит"</st><op>,</op> <st>"зелье"</st><op>}</op>
<kw>print</kw><op>(</op>items<op>[</op><nu>1</nu><op>]</op><op>)</op>  <cm>-- "меч"</cm>

<cm>-- Как словарь</cm>
<kw>local</kw> player <op>=</op> <op>{</op>
name <op>=</op> <st>"Герой"</st><op>,</op>
level <op>=</op> <nu>10</nu>
<op>}</op>
<kw>print</kw><op>(</op>player<op>.</op>name<op>)</op>  <cm>-- "Герой"</cm>
</code>

<h>Функция type()</h>
Возвращает строку с названием типа переменной:

<code>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><nu>42</nu><op>)</op><op>)</op>        <cm>-- "number"</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><st>"текст"</st><op>)</op><op>)</op>   <cm>-- "string"</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><kw>true</kw><op>)</op><op>)</op>      <cm>-- "boolean"</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><op>{}</op><op>)</op><op>)</op>        <cm>-- "table"</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><kw>nil</kw><op>)</op><op>)</op>       <cm>-- "nil"</cm>
</code>
]=],
}

ns_llua['lua'][5] = {
    type = "vartest",
    title = "Практика: Типы переменных",
    helpModules = {4, 3},
    tasks = {
        { var = "testNumber", type = "number",  desc = "Создай глобальную переменную testNumber с любым числом" },
        { var = "testString", type = "string",  desc = "Создай глобальную переменную testString с любой строкой" },
        { var = "testBool",   type = "boolean", desc = "Создай глобальную переменную testBool со значением true или false" },
        { var = "testNil",    type = "nil",     desc = "Обнули переменную testNil (сделай /run testNil = nil)" },
        { var = "testTable",  type = "table",   desc = "Создай глобальную переменную testTable с пустой таблицей {}" },
    },
}

ns_llua['lua'][6] = {
    type = "commenttest",
    title = "Практика: Комментарии",
    helpModules = {2},
    requiredPrintCount = 5,
    instruction = "Закомментируй строки 2 и 4, чтобы они не выполнялись. Остальные строки должны работать.",
    initialCode = [=[
print("Строка 1 - должна работать")
print("Строка 2 - закомментируй меня")
print("Строка 3 - должна работать")
print("Строка 4 - закомментируй меня")
print("Строка 5 - должна работать")
]=],
    expectedOutput = "Строка 1 - должна работать\nСтрока 3 - должна работать\nСтрока 5 - должна работать",
}

ns_llua['lua'][7] = {
    type = "info",
    title = "Функция print и форматирование",
    content = [=[
<h>Функция print</h>
<t>print</t> — это основная функция для вывода информации в чат. Она принимает любое количество аргументов и выводит их через табуляцию.

<t>Базовое использование:</t>
<code>
-- Вывод одного значения
print("Привет, мир!")

-- Вывод нескольких значений
print("Игрок:", "Герой", "Уровень:", 10)

-- Вывод чисел и результатов вычислений
print(5 + 3)
</code>

<h>Синтаксический сахар</h>
В Lua можно вызвать print без скобок, если аргумент один и это строка или таблица.

<code>
print "Привет"
print 'Привет'
print [[Привет]]
</code>

<w>Важно:</w> В заданиях курса лучше использовать вариант со скобками: <k>print(...)</k>.

<h>Конкатенация строк</h>
<t>Оператор ..</t> склеивает строки.

<code>
local name = "Герой"
local level = 10

print("Игрок " .. name .. " достиг " .. level .. " уровня")
print("Игрок", name, "достиг", level, "уровня")
</code>

<h>string.format</h>
<t>string.format</t> позволяет собрать строку по шаблону.

<t>Основные заполнители:</t>
- <k>%s</k> — строка
- <k>%d</k> — целое число
- <k>%.2f</k> — число с двумя знаками после запятой

<code>
local name = "Артас"
local level = 80

local message = string.format("%s (ур. %d)", name, level)
print(message)

print(string.format("Золото: %.2f", 1234.5678))
</code>
]=],
}

ns_llua['lua'][8] = {
    type = "printtest",
    title = "Практика: Простой print",
    helpModules = {7, 4},
    content = [=[
<h>Практика: простой print</h>
]=],
    tasks = {
        {
            desc = "Выведи фразу 'HELLO_WOW_123' через print",
            hint = "Используй /run print(\"HELLO_WOW_123\") или /run print('HELLO_WOW_123')",
            pattern = "HELLO_WOW_123",
            expectedExpression = {
                'print("HELLO_WOW_123")',
                "print('HELLO_WOW_123')",
            },
        },
        {
            desc = "Выведи число 777 через print",
            hint = "Используй /run print(777)",
            pattern = "777",
            expectedExpression = "print(777)",
        },
        {
            desc = "Выведи строку '777' через print",
            hint = "Используй /run print(\"777\") или /run print('777')",
            pattern = "777",
            expectedExpression = {
                'print("777")',
                "print('777')",
            },
        },
        {
            desc = "Выведи фразу 'SIMPLE_TEST_OK' через print",
            hint = "Используй /run print(\"SIMPLE_TEST_OK\") или /run print('SIMPLE_TEST_OK')",
            pattern = "SIMPLE_TEST_OK",
            expectedExpression = {
                'print("SIMPLE_TEST_OK")',
                "print('SIMPLE_TEST_OK')",
            },
        },
    },
}

ns_llua['lua'][9] = {
    type = "printtest",
    title = "Практика: Конкатенация",
    helpModules = {7},
    content = [=[
<h>Практика: конкатенация</h>
]=],
    tasks = {
        {
            desc = "Выведи фразу 'FOX BRAVO CHARLIE' через конкатенацию трёх слов с пробелами",
            hint = "Используй /run print(\"FOX\" .. \" BRAVO \" .. \"CHARLIE\")",
            pattern = "FOX BRAVO CHARLIE",
            requireConcat = true,
            requiredConcatCount = 2,
        },
        {
            desc = "Выведи фразу 'WOW-VERSION-335' через конкатенацию с дефисами",
            hint = "Используй /run print(\"WOW-\" .. \"VERSION-\" .. \"335\")",
            pattern = "WOW-VERSION-335",
            requireConcat = true,
            requiredConcatCount = 2,
        },
        {
            desc = "Выведи фразу 'ALPHA BETA GAMMA' через конкатенацию трёх частей с пробелами",
            hint = "Используй /run print(\"ALPHA\" .. \" BETA \" .. \"GAMMA\")",
            pattern = "ALPHA BETA GAMMA",
            requireConcat = true,
            requiredConcatCount = 2,
        },
    },
}

ns_llua['lua'][10] = {
    type = "info",
    title = "Математические операторы",
    content = [=[
<h>Работа с числами</h>
<t>В Lua числа имеют тип <k>number</k>. Отдельного целочисленного типа нет: и <k>7</k>, и <k>3.14</k> — это <k>number</k>.</t>

<code>
local num1 = 7
local num2 = 10
local num3 = num1 + num2

print(num3) -- 17
</code>

<w>Числа пишутся без кавычек, строки — в кавычках.</w>

<h>Основные операции</h>
<t>Над числами можно выполнять сложение, вычитание, умножение, деление, остаток от деления и возведение в степень.</t>

<code>
local a = 7
local b = 2

print(a + b) -- 9 (сложение)
print(a - b) -- 5 (вычитание)
print(a * b) -- 14 (умножение)
print(a / b) -- 3.5 (деление)
print(a % b) -- 1 (остаток от деления)
print(a ^ b) -- 49 (возведение в степень)
print(-a)    -- -7 (унарный минус - смена знака)
</code>

<t>Деление <k>/</k> всегда возвращает число с дробной частью.</t>
<t>Если нужна целая часть, используй <k>math.floor</k>:</t>

<code>
print(math.floor(7 / 2)) -- 3
</code>

<h>Порядок операций</h>
<t>Сначала выполняются умножение, деление и остаток, затем сложение и вычитание. Скобки меняют порядок.</t>

<code>
local num1 = 2 + 3 * 4
local num2 = (2 + 3) * 4

print(num1) -- 14
print(num2) -- 20
</code>

<h>Преобразование строки в число</h>
<t>Для явного преобразования строки в число используется <k>tonumber</k>.</t>

<code>
local s = "1992"
local year = tonumber(s)

print(year + 1) -- 1993
</code>

<t>В математических операциях Lua часто сама превращает строку в число:</t>

<code>
print("5" + 2) -- 7
</code>

<w>Если строка не похожа на число, будет ошибка:</w>

<code>
print("Привет" + 2) -- ошибка
</code>

<h>tonumber: когда возвращает nil</h>
<t>Функция <k>tonumber</k> пытается сделать из значения число. Важно не то, какого типа значение на входе, а то, получилось ли превращение.</t>
<t>Если получилось — вернётся число. Если не получилось — вернётся <k>nil</k>.</t>

<code>
print(tonumber("25"))   -- 25: строку "25" можно прочитать как число
print(tonumber("3.5"))  -- 3.5: дробная строка тоже превращается
print(tonumber(7))      -- 7: на входе уже число, tonumber вернул его как есть
print(tonumber("bad"))  -- nil: из "bad" число не сделать
print(tonumber("abc"))  -- nil: из "abc" число не сделать
</code>

<w>Главное:</w> <k>nil</k> здесь — это ответ «это не число». Не ошибка, не ноль, не пустая строка — именно <k>nil</k>.

<h>Зачем это нужно</h>
<t>Так как число в условии — истина, а <k>nil</k> — ложь, результатом <k>tonumber</k> можно проверять «а это вообще число?».</t>

<code>
local price = tonumber(v)   -- превращаем: число или nil
if price then               -- число = истина, nil = ложь
    print("это число")      -- выполнится только если превращение удалось
end                         -- закрываем условие
</code>

<t>Проверять саму строку через <k>if v then</k> бесполезно: любая строка, даже "bad", в Lua — истина. Разницу между "5" (цена текстом) и "bad" (мусор) видит только <k>tonumber</k>, потому что тип у обеих — <k>string</k>.</t>

<h>Короткое правило</h>
<t>Не гадай по типу, строка там или число. Скармливай значение <k>tonumber</k> и верь ответу: число — значит получилось, <k>nil</k> — значит нет. Один <k>tonumber</k> закрывает и строку-цену ("5"), и число-цену (7), и мусор ("bad").</t>

<h>Преобразование числа в строку</h>
<t>Для явного преобразования числа в строку используется <k>tostring</k>.</t>

<code>
local num = 17
local s = tostring(num)

print(s) -- "17"
</code>

<t>Оператор конкатенации <k>..</k> тоже автоматически превращает число в строку:</t>

<code>
print("Уровень: " .. 80) -- Уровень: 80
</code>

<h>Частые ошибки</h>
<code>
local num = 777
local str = "777"

print(type(num)) -- number
print(type(str)) -- string
</code>

<t>Основные ошибки:</t>
- записать число в кавычках и ожидать числовое поведение;
- ждать целое число после деления <k>/</k>;
- пытаться сложить число со строкой, которая не является числом;
- проверять саму строку через <k>if v then</k> вместо результата <k>tonumber(v)</k>: строка всегда истина, а «это число или нет» решает только <k>tonumber</k>.
]=],
}

ns_llua['lua'][11] = {
    type = "commenttest",
    title = "Практика: Множественное присваивание",
    helpModules = {1, 3, 4},

    preloadVars = {
        {var = "a", value = 1, desc = "a = 1"},
        {var = "b", value = 2, desc = "b = 2"},
    },

    content = [=[
<h>Множественное присваивание</h>
<t>В Lua можно присваивать значения сразу нескольким переменным в одной строке.</t>

<code>
x, y = 10, 20
</code>

<t>Сначала Lua вычисляет все выражения справа от знака равно, а затем присваивает результаты переменным слева.</t>

<code>
x, y = x + 1, y * 2
</code>

<t>Если справа значений больше, чем слева, лишние значения отбрасываются.</t>
<t>Если слева переменных больше, оставшиеся получают nil.</t>

<code>
local a, b = 1, 2, 3
local c, d = 1
</code>

<t>Эта особенность позволяет обменивать значения переменных без дополнительной переменной.</t>
]=],

    instruction = [=[
<h>Множественное присваивание</h>
<t>В Lua можно присваивать значения сразу нескольким переменным в одной строке.</t>

<code>
x, y = 10, 20
</code>

<t>Сначала Lua вычисляет все выражения справа от знака равно, а затем присваивает результаты переменным слева.</t>

<code>
x, y = x + 1, y * 2
</code>

<t>Если справа значений больше, чем слева, лишние значения отбрасываются.</t>
<t>Если слева переменных больше, оставшиеся получают nil.</t>

<h>Задание</h>
<t>Есть переменные:</t>

<code>
a = 1
b = 2
</code>

<t>Напиши одну строку, которая поменяет значения переменных <k>a</k> и <k>b</k> местами.</t>
<t>Нельзя использовать <k>local</k>, дополнительные переменные и несколько строк.</t>
]=],

    initialCode = [=[
-- Напиши здесь одну строку
]=],

    requireKeywords = {
        "a",
        "b",
        "=",
        ",",
    },

    onlyCodePatterns = true,
    singleLine = true,

    checkCode = function()
        return _G.a == 2 and _G.b == 1
    end,
}

ns_llua['lua'][12] = {
    type = "printtest",
    title = "Практика: GetAchievementInfo и преобразование типов",
    helpModules = {10, 11},

    preloadVars = {
        {
            var = "achieveId",
            value = 944,
            desc = "achieveId = 944 (number)",
        },
        {
            var = "achieveIdStr",
            value = "944",
            desc = 'achieveIdStr = "944" (string)',
        },
        {
            var = "exampleId",
            value = 521,
            desc = "exampleId = 521 (number)",
        },
        {
            var = "exampleIdStr",
            value = "521",
            desc = 'exampleIdStr = "521" (string)',
        },
        {
            var = "achieveName",
            value = "В том тоннеле меня любят!",
            desc = 'achieveName = "В том тоннеле меня любят!" (string)',
        },
        {
            var = "achievePoints",
            value = 15,
            desc = "achievePoints = 15 (number)",
        },
        {
            var = "achieveCompleted",
            value = false,
            desc = "achieveCompleted = false (boolean)",
        },
    },

    content = [=[
<h>Практика: GetAchievementInfo и преобразование типов</h>
<t>В игре есть функция <k>GetAchievementInfo</k>. Она возвращает информацию о достижении.</t>

<t>Посмотрим, как это работает, на примере достижения 521:</t>

<code>
/dump GetAchievementInfo(521)
</code>

<code>
[1]=521,
[2]="Превознесение среди 15 фракций",
[3]=10,
[4]=false,
[8]="Добейтесь того, чтобы вас превозносили 15 фракций.",
[9]=0,
[10]="Interface\Icons\Achievement_Reputation_03",
[11]=""
</code>

<t>То есть функция возвращает сразу несколько значений: ID, название, очки и другие данные.</t>

<t>Чтобы получить нужные значения, используй множественное присваивание:</t>

<code>
local id, name, points = GetAchievementInfo(521)
</code>

<t>В этом задании есть несколько переменных. Среди них есть числа, строки и boolean (узнай какой тип у какой):</t>

<code>
/run print(achieveId, type(achieveId))
/run print(achieveIdStr, type(achieveIdStr))
/run print(exampleId, type(exampleId))
/run print(exampleIdStr, type(exampleIdStr))
/run print(achieveName, type(achieveName))
/run print(achievePoints, type(achievePoints))
/run print(achieveCompleted, type(achieveCompleted))
</code>

<h>Задание 1</h>
<t>Выведи название достижения 944.</t>
<t>Не вставляй число 944 вручную. Используй подходящую переменную, в которой уже лежит число.</t>

<code>
/run local id, name = GetAchievementInfo(___); print(name)
</code>

<h>Задание 2</h>
<t>Снова выведи название достижения 944.</t>
<t>В этот раз используй переменную <k>achieveIdStr</k>. Это строка, поэтому её нужно преобразовать в число.</t>

<code>
/run local id, name = GetAchievementInfo(___); print(name)
</code>
]=],

    tasks = {
        {
            desc = "Выведи название достижения 944, используя правильную переменную",
            hint = "Используй переменную achieveId. Число 944 вручную вставлять нельзя.",
            pattern = "В том тоннеле меня любят!",

            requireKeywords = {
                "local",
                "GetAchievementInfo(achieveId)",
                "print",
            },

            forbidKeywords = {
                "944",
                "achieveIdStr",
                "achieveName",
            },
        },

        {
            desc = "Выведи название достижения 944, преобразовав переменную в число",
            hint = "achieveIdStr — это строка. Её нужно преобразовать в число.",
            pattern = "В том тоннеле меня любят!",

            requireKeywords = {
                "local",
                "GetAchievementInfo",
                "tonumber(achieveIdStr)",
                "print",
            },

            forbidKeywords = {
                "944",
                "achieveName",
            },
        },

    },
}

ns_llua['lua'][13] = {
    type = "printtest",
    title = "Практика: Числа и математика",
    helpModules = {10},
    content = [=[
<h>Практика: числа и математика</h>
]=],
    tasks = {
        {
            desc = "Выведи результат умножения 6 * 7",
            hint = "Используй /run print(6 * 7)",
            pattern = "42",
            expectedExpression = {
                "print(6*7)",
                "print(7*6)",
            },
        },
        {
            desc = "Выведи результат выражения 100 - 25",
            hint = "Используй /run print(100 - 25)",
            pattern = "75",
            expectedExpression = "print(100-25)",
        },
        {
            desc = "Выведи результат выражения 15 + 30 * 2",
            hint = "Используй /run print(15 + 30 * 2)",
            pattern = "75",
            expectedExpression = "print(15+30*2)",
        },
    },
}

ns_llua['lua'][14] = {
    type = "vartest",
    title = "Практика: string.format с переменными",
    helpModules = {7},

    content = [=[
<h>Что такое string.format</h>
<t>string.format</t> — это функция, которая собирает строку по шаблону.

В шаблоне есть специальные метки, а после шаблона перечисляются значения, которые на эти метки подставятся.

<t>Основные метки:</t>
- <k>%s</k> — строка
- <k>%d</k> — целое число
- <k>%.2f</k> — дробное число с двумя знаками после запятой

<t>Зачем это нужно:</t>
Чтобы не склеивать строку кусками через <k>..</k>, а сразу написать красивый и понятный шаблон.

<h>Пример</h>
Выполни готовую команду:

<code>
/run local itemName = "Меч"; local itemLevel = 25; print(string.format("Предмет: %s, уровень: %d", itemName, itemLevel))
</code>

<t>Что здесь происходит:</t>
- Шаблон: <s>"Предмет: %s, уровень: %d"</s>
- Первый аргумент после шаблона: <k>itemName</k>
- Второй аргумент после шаблона: <k>itemLevel</k>
- Метка <k>%s</k> заменяется на <k>itemName</k>
- Метка <k>%d</k> заменяется на <k>itemLevel</k>

<t>Вывод будет:</t>

<code>
Предмет: Меч, уровень: 25
</code>

<w>Важно:</w> Порядок аргументов имеет значение.

Первая метка получает первую переменную, вторая метка — вторую, и так далее.

<c>Здесь использованы local-переменные. Они живут только внутри одной команды /run.</c>

<h>Тест</h>
<t>Теперь создай переменные героя и выведи строку о герое с помощью string.format.</t>
]=],

    tasks = {
        {
            var = "heroName",
            desc = 'Создай глобальную переменную heroName = "Артас"',
            check = function(value)
                return type(value) == "string" and value == "Артас"
            end,
        },
        {
            var = "heroTitle",
            desc = 'Создай глобальную переменную heroTitle = "Король-лич"',
            check = function(value)
                return type(value) == "string" and value == "Король-лич"
            end,
        },
        {
            var = "heroLevel",
            desc = "Создай глобальную переменную heroLevel = 80",
            check = function(value)
                return type(value) == "number" and value == 80
            end,
        },
        {
            var = "heroHP",
            desc = "Создай глобальную переменную heroHP = 25000",
            check = function(value)
                return type(value) == "number" and value == 25000
            end,
        },
    },

    formatTask = {
        instruction = [=[
Используя string.format, выведи строку:

"Герой Артас (Король-лич) - Уровень: 80, HP: 25000"

Шаблон команды (заполни пропуски вместо ___ именами переменных):

/run print(string.format("Герой %s (%s) - Уровень: %d, HP: %d", ___, ___, ___, ___))

Подсказка:
- первый %s — имя героя;
- второй %s — титул героя;
- первый %d — уровень;
- второй %d — здоровье.
]=],
        pattern = "Герой Артас (Король-лич) - Уровень: 80, HP: 25000",
        requireKeywords = {
            "print",
            "string.format",
        },
    },
}

ns_llua['lua'][15] = {
    type = "info",
    title = "Сравнения и логические значения",
    content = [=[
<h>Сравнения и логические значения</h>
<t>Операторы сравнения нужны, чтобы сравнивать значения между собой. Результатом сравнения всегда является <k>boolean</k> — <k>true</k> или <k>false</k>.</t>
<code>
local result = 10 > 3
print(result)       -- true
print(type(result)) -- boolean
</code>

<h>1. Оператор равно</h>
<t>Записывается как <k>==</k>.</t>
<t>Правило:</t> возвращает <k>true</k>, если левое и правое значения равны.
<code>
print(5 == 5)         -- true
print(5 == 6)         -- false
print("Меч" == "Меч") -- true
print("Меч" == "Щит") -- false
</code>
<w>Важно:</w> один знак <k>=</k> — это присваивание, а два знака <k>==</k> — это сравнение.
<code>
local level = 80     -- присваивание
print(level == 80)   -- сравнение, вернёт true
</code>

<h>2. Оператор не равно</h>
<t>Записывается как <k>~=</k>.</t>
<t>Правило:</t> возвращает <k>true</k>, если значения НЕ равны.
<code>
print(7 ~= 7)         -- false
print(7 ~= 8)         -- true
print("лук" ~= "меч") -- true
</code>

<h>3. Оператор больше</h>
<t>Записывается как <k>></k>.</t>
<t>Правило:</t> возвращает <k>true</k>, если левое значение больше правого.
<code>
print(10 > 3) -- true
print(3 > 10) -- false
print(5 > 5)  -- false
</code>

<h>4. Оператор меньше</h>
<t>Записывается как <k><</k>.</t>
<t>Правило:</t> возвращает <k>true</k>, если левое значение меньше правого.
<code>
print(3 < 10) -- true
print(10 < 3) -- false
print(5 < 5)  -- false
</code>

<h>5. Оператор больше или равно</h>
<t>Записывается как <k>>=</k>.</t>
<t>Правило:</t> возвращает <k>true</k>, если левое значение больше или равно правому.
<code>
print(8 >= 8) -- true
print(9 >= 8) -- true
print(7 >= 8) -- false
</code>

<h>6. Оператор меньше или равно</h>
<t>Записывается как <k><=</k>.</t>
<t>Правило:</t> возвращает <k>true</k>, если левое значение меньше или равно правому.
<code>
print(7 <= 8) -- true
print(8 <= 8) -- true
print(9 <= 8) -- false
</code>

<h>Шпаргалка по операторам сравнения</h>
<c>== — равно</c>
<c>~= — не равно</c>
<c>> — больше</c>
<c>< — меньше</c>
<c>>= — больше или равно</c>
<c><= — меньше или равно</c>

<h>Логические значения</h>
<t>Тип <k>boolean</k> имеет только два значения:</t>
<t><k>true</k> — истина.</t>
<t><k>false</k> — ложь.</t>
<code>
local isAlive = true
local isDead = false
print(type(isAlive)) -- boolean
print(type(isDead))  -- boolean
</code>

<h>Оператор not</h>
<t>Записывается как <k>not</k>.</t>
<t>Правило:</t> оператор <k>not</k> переворачивает логическое значение.
<t>Если значение ложное, то <k>not</k> вернёт <k>true</k>. Если значение истинное, то <k>not</k> вернёт <k>false</k>.</t>
<code>
print(not true)  -- false
print(not false) -- true
print(not nil)   -- true
</code>
<t>В Lua ложными считаются только <k>false</k> и <k>nil</k>. Поэтому числа, строки и таблицы дают <k>false</k> после <k>not</k>:</t>
<code>
print(not 0)   -- false
print(not "")  -- false
print(not {})  -- false
</code>
<w>Важно:</w> результат оператора <k>not</k> всегда имеет тип <k>boolean</k>.
<code>
local value = 0
print(type(not value)) -- boolean
</code>
<t>Пример с условием:</t>
<code>
local isDead = false
if not isDead then
    print("Персонаж жив!")
end
</code>
<t>Двойное отрицание можно использовать, чтобы превратить любое значение в <k>true</k> или <k>false</k>:</t>
<code>
print(not not 0)   -- true
print(not not nil) -- false
</code>

<h>Шпаргалка по not</h>
<c>not true = false</c>
<c>not false = true</c>
<c>not nil = true</c>
<c>not 0 = false</c>
<c>not "" = false</c>
<c>not {} = false</c>

<h>Что в Lua считается ложью</h>
<w>Очень важно:</w> в Lua только <k>false</k> и <k>nil</k> считаются ложными. Всё остальное — <k>true</k>.
<code>
if 0 then
    print("0 считается true")
end

if "" then
    print("Пустая строка считается true")
end

if {} then
    print("Пустая таблица считается true")
end
</code>

<h>nil и false — не одно и то же</h>
<t><k>nil</k> означает отсутствие значения, а <k>false</k> — логическую ложь. При сравнении они не равны.</t>
<code>
print(nil == false) -- false
print(nil ~= false) -- true
</code>

<h>Сравнение чисел и строк</h>
<t>Число и строка с таким же текстом — это разные значения.</t>
<code>
print(777 == "777") -- false
print(type(777))    -- number
print(type("777"))  -- string
</code>
<t>Если строку нужно сравнить как число, её можно преобразовать:</t>
<code>
print(tonumber("777") == 777) -- true
</code>

<h>Частые ошибки</h>
<w>Ошибка 1:</w> использовать один знак <k>=</k> вместо <k>==</k> в условии.
<code>
-- неправильно
if level = 80 then
    print("Максимальный уровень")
end

-- правильно
if level == 80 then
    print("Максимальный уровень")
end
</code>

<w>Ошибка 2:</w> думать, что <k>nil</k> и <k>false</k> — это одно и то же.
<code>
print(nil == false) -- false
</code>

<w>Ошибка 3:</w> сравнивать число со строкой без преобразования.
<code>
print(777 == "777")           -- false
print(tonumber("777") == 777) -- true
</code>

<w>Ошибка 4:</w> ожидать, что <k>not 0</k> даст <k>true</k>.
<t>В некоторых языках 0 считается ложью, но в Lua 0 — это <k>true</k>. Поэтому:</t>
<code>
print(not 0) -- false
</code>

<h>Где это используется</h>
<t>Сравнения чаще всего используются внутри условий <k>if</k>:</t>
<code>
local hp = 85
if hp > 60 then
    print("Боеспособен")
end
</code>
<t>Оператор <k>not</k> часто используется, чтобы проверить обратное условие:</t>
<code>
local inCombat = false
if not inCombat then
    print("Можно спокойно отдохнуть")
end
</code>
]=],
}

ns_llua['lua'][16] = {
    type = "printtest",
    title = "Практика: Сравнения",
    helpModules = {15, 4},
    content = [=[
<h>Практика: сравнения</h>
<t>Выведи результат сравнения через <k>print</k>.</t>
<t>Задания проверяются по очереди.</t>
]=],
    tasks = {
        {
            desc = "Выведи результат 5 == 5",
            hint = "Используй /run print(5 == 5)",
            pattern = "true",
            requireKeywords = {"print", "5==5"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат 7 ~= 7",
            hint = "Используй /run print(7 ~= 7)",
            pattern = "false",
            requireKeywords = {"print", "7~=7"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат 10 > 3",
            hint = "Используй /run print(10 > 3)",
            pattern = "true",
            requireKeywords = {"print", "10>3"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат 10 < 3",
            hint = "Используй /run print(10 < 3)",
            pattern = "false",
            requireKeywords = {"print", "10<3"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат 8 >= 8",
            hint = "Используй /run print(8 >= 8)",
            pattern = "true",
            requireKeywords = {"print", "8>=8"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат 8 <= 7",
            hint = "Используй /run print(8 <= 7)",
            pattern = "false",
            requireKeywords = {"print", "8<=7"},
            forbidKeywords = {"true", "false", "nil"},
        },
    },
}

ns_llua['lua'][17] = {
    type = "info",
    title = "Простые условия if",
    content = [=[
<h>Простые условия if</h>
<t>Конструкция <k>if</k> выполняет код, если условие истинно.</t>
<code>
local hp = 80
if hp > 60 then
    print("Боеспособен")
end
</code>
<t>Если нужно выбрать один из двух вариантов, используй <k>else</k>.</t>
<code>
local hp = 40
if hp > 60 then
    print("Боеспособен")
else
    print("Нужен отдых")
end
</code>
<w>Важно:</w> Каждый <k>if</k> закрывается словом <k>end</k>.
]=],
}

ns_llua['lua'][18] = {
    type = "commenttest",
    title = "Практика: Простое условие if",
    helpModules = {17, 15},
    preloadVars = {
        {var = "playerMana", value = 40, desc = "playerMana = 40"},
    },
    instruction = [=[
<h>Практика: простое условие if</h>
<t>Переменная <k>playerMana</k> уже равна 40.</t>
<t>Напиши условие: если <k>playerMana</k> больше или равно 30, выведи <s>"Достаточно маны"</s>.</t>
<t>Иначе выведи <s>"Мало маны"</s>.</t>
<t>Выведи только одну строку.</t>
<w>Подсказка:</w> используй конструкцию if / then / else / end.
]=],
    initialCode = [=[
-- Напиши условие здесь
]=],
    expectedOutput = "Достаточно маны",
    requireKeywords = {"playerMana", ">=", "30", "if", "then", "else", "end", "print"},
}

ns_llua['lua'][19] = {
    type = "info",
    title = "Ветвление: if / elseif / else",
    content = [=[
<h>Ветвление: if / elseif / else</h>
<t>Конструкция <k>if / elseif / else</k> позволяет выбрать один из нескольких путей.</t>
<code>
local percent = 25
if percent >= 80 then
    print("Здоровье отличное!")
elseif percent >= 40 then
    print("Нужно подлечиться")
else
    print("СРОЧНО ЛЕЧИСЬ!")
end
</code>
<t>Как только одно условие сработало, остальные <k>elseif</k> и <k>else</k> пропускаются.</t>
<w>Важно:</w> <k>else</k> должен быть последним, а весь блок закрывается словом <k>end</k>.
]=],
}

ns_llua['lua'][20] = {
    type = "commenttest",
    title = "Практика: if / elseif / else",
    helpModules = {19, 17},
    preloadVars = {
        {var = "arenaRating", value = 1450, desc = "arenaRating = 1450"},
    },
    instruction = [=[
<h>Практика: if / elseif / else</h>
<t>Переменная <k>arenaRating</k> уже равна 1450.</t>
<t>Напиши условие с тремя ветками:</t>
<t>Если <k>arenaRating</k> больше или равно 1500, выведи <s>"Высокий рейтинг"</s>.</t>
<t>Иначе, если <k>arenaRating</k> больше или равно 1200, выведи <s>"Средний рейтинг"</s>.</t>
<t>Иначе выведи <s>"Низкий рейтинг"</s>.</t>
<t>Выведи только одну строку.</t>
<w>Подсказка:</w> используй конструкцию if / elseif / else / end.
]=],
    initialCode = [=[
-- Напиши условие здесь
]=],
    expectedOutput = "Средний рейтинг",
    requireKeywords = {"arenaRating", ">=", "1500", "1200", "if", "elseif", "else", "end", "print"},
}

ns_llua['lua'][21] = {
    type = "info",
    title = "Логические операторы and / or / not",
    content = [=[
<h>Логические операторы and / or / not</h>
<t>Оператор <k>and</k> возвращает <k>true</k>, только если оба условия истинны.</t>
<code>
local hp = 5000
local mana = 3000
if hp > 0 and mana > 1000 then
    print("Можно атаковать и кастовать")
end
</code>
<t>Оператор <k>or</k> возвращает <k>true</k>, если истинно хотя бы одно условие.</t>
<code>
local class = "Воин"
if class == "Воин" or class == "Паладин" then
    print("Можно носить латы!")
end
</code>
<t>Оператор <k>not</k> переворачивает логическое значение.</t>
<code>
local isDead = false
if not isDead then
    print("Персонаж жив!")
end
</code>
<h>Частая ошибка</h>
<w>Неправильно:</w>
<code>
local class = "Маг"
if class == "Воин" or "Паладин" then
    print("Можно носить латы!")
end
</code>
<t>Здесь вторая часть — просто строка <s>"Паладин"</s>, а любая строка в Lua считается <k>true</k>. Поэтому условие всегда будет истинным.</t>
<ok>Правильно:</ok>
<code>
local class = "Маг"
if class == "Воин" or class == "Паладин" then
    print("Можно носить латы!")
end
</code>
]=],
}

ns_llua['lua'][22] = {
    type = "printtest",
    title = "Практика: and / or / not",
    helpModules = {21, 15},
    content = [=[
<h>Практика: and / or / not</h>
<t>Выведи результат логического выражения через <k>print</k>.</t>
<t>Задания проверяются по очереди.</t>
]=],
    tasks = {
        {
            desc = "Выведи результат 5 > 3 and 10 > 7",
            hint = "Используй /run print(5 > 3 and 10 > 7)",
            pattern = "true",
            requireKeywords = {"print", "and", "5>3", "10>7"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат 5 > 3 and 10 < 7",
            hint = "Используй /run print(5 > 3 and 10 < 7)",
            pattern = "false",
            requireKeywords = {"print", "and", "5>3", "10<7"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат 5 < 3 or 10 > 7",
            hint = "Используй /run print(5 < 3 or 10 > 7)",
            pattern = "true",
            requireKeywords = {"print", "or", "5<3", "10>7"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат 5 < 3 or 10 < 7",
            hint = "Используй /run print(5 < 3 or 10 < 7)",
            pattern = "false",
            requireKeywords = {"print", "or", "5<3", "10<7"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат not (5 < 3)",
            hint = "Используй /run print(not (5 < 3))",
            pattern = "true",
            requireKeywords = {"print", "not", "5<3"},
            forbidKeywords = {"true", "false", "nil"},
        },
        {
            desc = "Выведи результат not nil",
            hint = "Используй /run print(not nil)",
            pattern = "true",
            requireKeywords = {"print", "not", "nil"},
            forbidKeywords = {"true", "false"},
        },
    },
}

ns_llua['lua'][23] = {
    type = "commenttest",
    title = "Практика: and / or / not в условии",
    helpModules = {21, 19},
    preloadVars = {
        {var = "isAlive", value = true, desc = "isAlive = true"},
        {var = "inCombat", value = false, desc = "inCombat = false"},
        {var = "playerLevel", value = 70, desc = "playerLevel = 70"},
    },
    instruction = [=[
<h>Практика: and / or / not в условии</h>
<t>Переменные уже созданы:</t>
<code>
isAlive = true
inCombat = false
playerLevel = 70
</code>
<t>Напиши условие: если персонаж жив, не в бою и его уровень не меньше 60, выведи <s>"Готов к рейду"</s>. Иначе выведи <s>"Не готов"</s>.</t>
<t>Используй <k>and</k>, <k>not</k> и сравнение <k>>=</k>.</t>

]=],
    initialCode = [=[
-- Напиши условие здесь
]=],
    expectedOutput = "Готов к рейду",
    requireKeywords = {"isAlive", "inCombat", "playerLevel", "and", "not", ">=", "60", "if", "then", "else", "end", "print"},
}

ns_llua['lua'][24] = {
    type = "commenttest",
    title = "Комбо-тест: переменные, типы и type",
    helpModules = {4, 15},
    instruction = [=[
<h>Комбо-тест: переменные, типы и type</h>
<t>Создай глобальные переменные:</t>
<t><k>playerName</k> — любая непустая строка.</t>
<t><k>playerLevel</k> — любое число.</t>
<t><k>playerOnline</k> — любое логическое значение.</t>
<t><k>playerType</k> — строка с типом переменной <k>playerLevel</k>. Используй функцию <k>type</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {"playerName", "playerLevel", "playerOnline", "playerType", "type"},
    checkCode = function()
        return type(_G.playerName) == "string"
            and _G.playerName ~= ""
            and type(_G.playerLevel) == "number"
            and type(_G.playerOnline) == "boolean"
            and _G.playerType == "number"
    end,
}

ns_llua['lua'][25] = {
    type = "printtest",
    title = "Комбо-тест: print, математика и конкатенация",
    helpModules = {7, 10},
    content = [=[
<h>Комбо-тест: print, математика и конкатенация</h>
<t>Выполни задания по очереди через <k>/run</k>.</t>
]=],
    tasks = {
        {
            desc = "Выведи результат выражения 7 + 3 * 2",
            pattern = "13",
            requireKeywords = {"print", "7", "3", "2", "+", "*"},
            forbidKeywords = {"13"},
        },
        {
            desc = "Выведи фразу LEVEL 80, склеив три части: слово LEVEL, пробел и число 80",
            pattern = "LEVEL 80",
            requireConcat = true,
            requiredConcatCount = 2,
            requireKeywords = {"print", "LEVEL", "80", ".."},
            forbidKeywords = {"LEVEL 80"},
        },
        {
            desc = "Выведи остаток от деления 17 на 5",
            pattern = "2",
            requireKeywords = {"print", "17", "5", "%"},
        },
    },
}

ns_llua['lua'][26] = {
    type = "commenttest",
    title = "Комбо-тест: tonumber и string.format",
    helpModules = {7, 10},
    preloadVars = {
        {var = "itemName", value = "Клинок", desc = "itemName = \"Клинок\""},
        {var = "itemLevel", value = "25", desc = "itemLevel = \"25\""},
        {var = "itemCount", value = 3, desc = "itemCount = 3"},
    },
    instruction = [=[
<h>Комбо-тест: tonumber и string.format</h>
<t>Уже созданы переменные:</t>
<t><k>itemName</k> = "Клинок" (строка).</t>
<t><k>itemLevel</k> = "25" (строка).</t>
<t><k>itemCount</k> = 3 (число).</t>
<t>Создай глобальную переменную <k>itemLevelNumber</k>: преобразуй <k>itemLevel</k> в число.</t>
<t>Создай глобальную переменную <k>report</k> с помощью <k>string.format</k> по шаблону:</t>
<s>"Предмет: %s, уровень: %d, количество: %d"</s>
<t>В шаблон нужно подставить: имя предмета, числовой уровень и количество.</t>
<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {"itemName", "itemLevel", "itemCount", "itemLevelNumber", "report", "tonumber", "string.format"},
    checkCode = function()
        return type(_G.itemLevelNumber) == "number"
            and _G.itemLevelNumber == 25
            and _G.report == "Предмет: Клинок, уровень: 25, количество: 3"
    end,
}

ns_llua['lua'][27] = {
    type = "commenttest",
    title = "Комбо-тест: множественное присваивание",
    helpModules = {11, 1},
    preloadVars = {
        {var = "a", value = 5, desc = "a = 5"},
        {var = "b", value = 8, desc = "b = 8"},
        {var = "c", value = 3, desc = "c = 3"},
    },
    instruction = [=[
<h>Комбо-тест: множественное присваивание</h>
<t>Уже созданы переменные:</t>
<t><k>a</k> = 5, <k>b</k> = 8, <k>c</k> = 3.</t>
<t>Напиши одну строку множественного присваивания, чтобы значения повернулись по кругу:</t>
<t><k>a</k> должно стать 8, <k>b</k> должно стать 3, <k>c</k> должно стать 5.</t>
<t>Нельзя использовать <k>local</k>, дополнительные переменные и несколько строк.</t>
]=],
    initialCode = [=[
-- Напиши одну строку здесь
]=],
    requireKeywords = {"a", "b", "c", "=", ","},
    singleLine = true,
    checkCode = function()
        return _G.a == 8 and _G.b == 3 and _G.c == 5
    end,
}

ns_llua['lua'][28] = {
    type = "commenttest",
    title = "Комбо-тест: if, and, or, not",
    helpModules = {17, 19, 21},
    preloadVars = {
        {var = "hp", value = 60, desc = "hp = 60"},
        {var = "mana", value = 40, desc = "mana = 40"},
        {var = "inCombat", value = false, desc = "inCombat = false"},
    },
    instruction = [=[
<h>Комбо-тест: if, and, or, not</h>
<t>Уже созданы переменные:</t>
<t><k>hp</k> = 60, <k>mana</k> = 40, <k>inCombat</k> = false.</t>
<t>Создай глобальную переменную <k>status</k> с помощью условия:</t>
<t>Если <k>inCombat</k> или <k>hp</k> меньше 20, значение должно быть <s>"Бой"</s>.</t>
<t>Иначе, если <k>mana</k> больше или равно 50 и персонаж не в бою, значение должно быть <s>"Магия"</s>.</t>
<t>Иначе значение должно быть <s>"Ожидание"</s>.</t>
<t>Используй <k>if</k>, <k>elseif</k>, <k>else</k> и <k>end</k>. Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {"hp", "mana", "inCombat", "status", "if", "elseif", "else", "end", "or", "and", "not"},
    checkCode = function()
        return _G.status == "Ожидание"
    end,
}

ns_llua['lua'][29] = {
    type = "commenttest",
    title = "Комбо-тест: таблица, # и индексы",
    helpModules = {4},
    instruction = [=[
<h>Оператор # для таблиц</h>
<t>Оператор <k>#</k> можно применять к таблицам. Для таблицы-списка он возвращает количество элементов.</t>
<code>
local example = {"Меч", "Щит"}
print(#example) -- 2
</code>

<w>Важно:</w> предупреждение про <k>#</k> и кириллицу касается строк.
<t>В WoW 3.3.5 для строк <k>#</k> считает байты, а не символы. Поэтому длина строки с кириллицей может быть больше, чем количество букв.</t>
<t>Но здесь мы применяем <k>#</k> к таблице, поэтому содержимое строк не влияет на количество элементов.</t>

<h>Задание</h>
<t>Создай глобальную таблицу <k>bag</k> с четырьмя строками по порядку:</t>
<t>"Факел", "Верёвка", "Кремень", "Компас".</t>
<t>Создай глобальную переменную <k>bagCount</k> с количеством элементов в таблице. Используй оператор <k>#</k>.</t>
<t>Создай глобальную переменную <k>firstItem</k> с первым элементом таблицы.</t>
<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {"bag", "bagCount", "firstItem", "#bag", "bag[1]", "Факел", "Верёвка", "Кремень", "Компас"},
    checkCode = function()
        return type(_G.bag) == "table"
            and _G.bag[1] == "Факел"
            and _G.bag[2] == "Верёвка"
            and _G.bag[3] == "Кремень"
            and _G.bag[4] == "Компас"
            and _G.bagCount == 4
            and _G.firstItem == "Факел"
    end,
}

ns_llua['lua'][30] = {
    type = "commenttest",
    title = "Итоговый комбо-тест",
    helpModules = {7, 10, 17, 19, 21},
    preloadVars = {
        {var = "playerLevel", value = 75, desc = "playerLevel = 75"},
        {var = "maxLevel", value = 80, desc = "maxLevel = 80"},
        {var = "isAlive", value = true, desc = "isAlive = true"},
        {var = "gold", value = "1500", desc = "gold = \"1500\""},
    },
    instruction = [=[
<h>Итоговый комбо-тест</h>
<t>Уже созданы переменные:</t>
<t><k>playerLevel</k> = 75, <k>maxLevel</k> = 80, <k>isAlive</k> = true, <k>gold</k> = "1500".</t>
<t>Создай глобальную переменную <k>goldNumber</k>: преобразуй <k>gold</k> в число.</t>
<t>Создай глобальную переменную <k>levelText</k> с помощью условия:</t>
<t>Если <k>playerLevel</k> больше или равно <k>maxLevel</k>, значение должно быть <s>"Максимум"</s>, иначе <s>"Расти"</s>.</t>
<t>Создай глобальную переменную <k>canTrade</k> с помощью условия:</t>
<t>Если <k>isAlive</k> и <k>goldNumber</k> больше или равно 1000, значение должно быть <k>true</k>, иначе <k>false</k>.</t>
<t>Создай глобальную переменную <k>summary</k> с помощью <k>string.format</k> по шаблону:</t>
<s>"Уровень: %d, Золото: %d"</s>
<t>В шаблон нужно подставить <k>playerLevel</k> и <k>goldNumber</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {"playerLevel", "maxLevel", "isAlive", "gold", "goldNumber", "levelText", "canTrade", "summary", "tonumber", "if", "then", "else", "end", "and", "string.format"},
    checkCode = function()
        return type(_G.goldNumber) == "number"
            and _G.goldNumber == 1500
            and _G.levelText == "Расти"
            and _G.canTrade == true
            and _G.summary == "Уровень: 75, Золото: 1500"
    end,
}

ns_llua['lua'][31] = {
    type = "info",
    title = "Циклы: for",
    helpModules = {4, 7},
    content = [=[
<h>Цикл for</h>
<t>Цикл <k>for</k> нужен, чтобы повторять код нужное количество раз.</t>
<t>Он сам меняет переменную цикла и сам останавливается, когда диапазон закончится.</t>

<h>Числовой for</h>
<code>
for i = 1, 5 do -- начинаем цикл: переменная i будет принимать значения 1, 2, 3, 4, 5
    print(i) -- выводим текущее значение i в чат
end -- закрываем цикл
</code>

<h>Обратный отсчёт</h>
<t>Третье число в <k>for</k> — это шаг. Если шаг отрицательный, цикл идёт назад.</t>
<code>
for i = 5, 1, -1 do -- i меняется от 5 до 1 с шагом -1
    print(i) -- выводим 5, 4, 3, 2, 1
end -- закрываем цикл
</code>

<h>Накопление суммы</h>
<t>Часто внутри цикла накапливают результат в отдельной переменной.</t>
<code>
local sum = 0 -- создаём переменную для накопления суммы
for i = 1, 5 do -- проходим числа от 1 до 5
    sum = sum + i -- прибавляем текущее значение i к сумме
end -- завершаем цикл
print(sum) -- выводим итоговую сумму: 15
</code>

<h>Накопление строки</h>
<t>Точно так же можно собирать строку через конкатенацию.</t>
<code>
local text = "" -- создаём пустую строку для результата
for i = 1, 3 do -- проходим числа от 1 до 3
    text = text .. i .. " " -- приклеиваем число и пробел к строке
end -- завершаем цикл
print(text) -- выводим "1 2 3 "
</code>

<h>Перебор таблицы через ipairs</h>
<t>Если у тебя таблица-список, её удобно перебирать через <k>ipairs</k>.</t>
<code>
local items = {"Меч", "Щит"} -- создаём таблицу-список из двух предметов
for index, value in ipairs(items) do -- перебираем элементы по порядку
    print(index) -- выводим номер элемента: сначала 1, потом 2
    print(value) -- выводим значение: сначала "Меч", потом "Щит"
end -- завершаем цикл
</code>

<h>Важно для практики</h>
<t>В практических модулях курса проверяются глобальные переменные.</t>
<t>Поэтому нужные переменные создавай без <k>local</k>, если задание просит сохранить результат для проверки.</t>
]=],
}

ns_llua['lua'][32] = {
    type = "info",
    title = "Циклы: while",
    helpModules = {31},
    content = [=[
<h>Цикл while</h>
<t>Цикл <k>while</k> повторяет код, пока условие истинно.</t>
<t>В отличие от числового <k>for</k>, здесь ты сам следишь за тем, когда цикл должен остановиться.</t>

<h>Обычный while</h>
<code>
local count = 0 -- создаём переменную-счётчик
while count < 3 do -- повторяем цикл, пока count меньше 3
    print(count) -- выводим текущее значение счётчика
    count = count + 1 -- увеличиваем счётчик на 1
end -- закрываем цикл
</code>

<h>Бесконечный цикл</h>
<t>Если условие всегда истинно, цикл будет выполняться бесконечно.</t>
<code>
while true do -- условие всегда равно true
    print("Это будет повторяться бесконечно") -- выводим сообщение каждый раз
end -- цикл не останавливается сам
</code>
<w>Опасность:</w> такой цикл может зависнуть, если внутри нет выхода через <k>break</k> или другого способа остановки.

<h>Бесконечный цикл с break</h>
<t>Иногда цикл делают бесконечным, но останавливают вручную через <k>break</k>.</t>
<code>
local count = 0 -- создаём переменную-счётчик
while true do -- начинаем бесконечный цикл
    count = count + 1 -- увеличиваем счётчик на 1
    if count >= 3 then -- проверяем, пора ли остановиться
        break -- выходим из цикла
    end -- закрываем условие if
end -- закрываем цикл while
print(count) -- выводим 3
</code>

<h>Частая ошибка</h>
<t>Если забыть изменить счётчик, цикл станет бесконечным.</t>
<code>
local count = 0 -- создаём переменную-счётчик
while count < 3 do -- условие изначально истинно
    print(count) -- выводим count
    -- здесь забыли count = count + 1, поэтому цикл никогда не закончится
end -- закрываем цикл
</code>
]=],
}

ns_llua['lua'][33] = {
    type = "info",
    title = "Поиск подстроки: string.find",
    helpModules = {31, 32},
    content = [=[
<h>string.find</h>
<t>Функция <k>string.find</k> ищет часть строки внутри другой строки.</t>
<t>Если подстрока найдена, функция возвращает позицию.</t>
<t>Если подстрока не найдена, функция возвращает <k>nil</k>.</t>

<h>Простой пример</h>
<code>
local pos = string.find("molot", "ol") -- ищем "ol" внутри слова "molot"
print(pos) -- выводим 2, потому что совпадение начинается со второго символа
local notFound = string.find("shield", "ol") -- ищем "ol" внутри слова "shield"
print(notFound) -- выводим nil, потому что совпадения нет
</code>

<h>string.find в условии</h>
<t>Так как найденная позиция считается истиной, а <k>nil</k> — ложью, <k>string.find</k> удобно использовать в <k>if</k>.</t>
<code>
if string.find("kolco", "ol") then -- если внутри "kolco" есть "ol", условие истинно
    print("Найдено") -- этот код выполнится
end -- закрываем условие
</code>

<h>Поиск по таблице слов</h>
<t>Можно пройтись циклом по таблице и проверить каждое слово.</t>
<code>
local items = {"Меч", "Молот", "Щит"} -- создаём таблицу со словами
local found = "" -- создаём пустую строку для найденных слов
for _, v in ipairs(items) do -- перебираем каждое слово из таблицы
    if string.find(v, "ол") then -- если внутри текущего слова есть "ол"
        found = found .. v .. " " -- добавляем слово в результат
    end -- закрываем условие
end -- закрываем цикл
print(found) -- выводим "Молот "
</code>

<h>Важно про кириллицу</h>
<t>В WoW 3.3.5 позиции в строке считаются в байтах, а не в символах.</t>
<t>Поэтому для кириллицы номер позиции может быть больше, чем номер буквы.</t>
<t>Но для проверки «найдено / не найдено» это не мешает: главное, что возвращается число или <k>nil</k>.</t>
]=],
}

ns_llua['lua'][34] = {
    type = "commenttest",
    title = "Практика: for и сборка строки",
    helpModules = {31, 7},
    preloadVars = {
        {var = "numberSequence", desc = "numberSequence очищается перед проверкой"},
    },
    instruction = [=[
<h>Практика: for и сборка строки</h>
<t>Создай глобальную переменную <k>numberSequence</k>.</t>
<t>Собери в неё числа от 10 до 15 через пробел.</t>
<t>В конце строки тоже должен быть пробел.</t>

<t>Ожидаемое значение:</t>
<s>"10 11 12 13 14 15 "</s>

<t>Используй:</t>
<t>- цикл <k>for</k>;</t>
<t>- конкатенацию;</t>
<t>- накопление результата в переменную <k>numberSequence</k>.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "numberSequence",
        "for",
        "do",
        "end",
        "10",
        "15",
        "numberSequence=numberSequence..",
    },
    checkCode = function()
        return type(_G.numberSequence) == "string"
            and _G.numberSequence == "10 11 12 13 14 15 "
    end,
}

ns_llua['lua'][35] = {
    type = "commenttest",
    title = "Практика: for, условие и сумма",
    helpModules = {31, 10, 17, 19},
    preloadVars = {
        {var = "totalSum", desc = "totalSum очищается перед проверкой"},
    },
    instruction = [=[
<h>Практика: for, условие и сумма</h>
<t>Создай глобальную переменную <k>totalSum</k>.</t>
<t>Посчитай сумму чисел от 1 до 10, которые больше 5.</t>

<t>То есть нужно сложить:</t>
<s>6 + 7 + 8 + 9 + 10</s>

<t>Ожидаемое значение:</t>
<s>40</s>

<t>Используй:</t>
<t>- цикл <k>for</k>;</t>
<t>- условие <k>if</k>;</t>
<t>- прибавление к <k>totalSum</k>.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "totalSum",
        "for",
        "do",
        "end",
        "if",
        "then",
        ">",
        "5",
        "totalSum=totalSum+",
    },
    checkCode = function()
        return type(_G.totalSum) == "number"
            and _G.totalSum == 40
    end,
}

ns_llua['lua'][36] = {
    type = "commenttest",
    title = "Практика: for и string.format",
    helpModules = {31, 7, 14},
    preloadVars = {
        {var = "levelReport", desc = "levelReport очищается перед проверкой"},
    },
    instruction = [=[
<h>Практика: for и string.format</h>
<t>Создай глобальную переменную <k>levelReport</k>.</t>
<t>Собери строку для уровней 1, 2 и 3.</t>

<t>Для каждого уровня нужно добавить фрагмент:</t>
<s>"Уровень: %d "</s>

<t>Ожидаемое значение:</t>
<s>"Уровень: 1 Уровень: 2 Уровень: 3 "</s>

<t>Используй:</t>
<t>- цикл <k>for</k> от 1 до 3;</t>
<t>- <k>string.format</k>;</t>
<t>- конкатенацию в переменную <k>levelReport</k>.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "levelReport",
        "for",
        "do",
        "end",
        "string.format",
        "%d",
        "Уровень:",
        "levelReport=levelReport..",
    },
    checkCode = function()
        return type(_G.levelReport) == "string"
            and _G.levelReport == "Уровень: 1 Уровень: 2 Уровень: 3 "
    end,
}

ns_llua['lua'][37] = {
    type = "commenttest",
    title = "Практика: while и счётчик",
    helpModules = {32, 7},
    preloadVars = {
        {var = "whileResult", desc = "whileResult очищается перед проверкой"},
    },
    instruction = [=[
<h>Практика: while и счётчик</h>
<t>Создай глобальную переменную <k>whileResult</k>.</t>
<t>Собери в неё числа от 0 до 4 через пробел.</t>
<t>В конце строки тоже должен быть пробел.</t>

<t>Ожидаемое значение:</t>
<s>"0 1 2 3 4 "</s>

<t>Используй:</t>
<t>- цикл <k>while</k>;</t>
<t>- переменную-счётчик <k>count</k>;</t>
<t>- условие <k>count < 5</k>;</t>
<t>- увеличение счётчика на 1;</t>
<t>- конкатенацию в переменную <k>whileResult</k>.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "whileResult",
        "while",
        "do",
        "end",
        "count",
        "<",
        "5",
        "whileResult=whileResult..",
        "count=count+1",
    },
    checkCode = function()
        return type(_G.whileResult) == "string"
            and _G.whileResult == "0 1 2 3 4 "
    end,
}

ns_llua['lua'][38] = {
    type = "commenttest",
    title = "Практика: while, break и остаток от деления",
    helpModules = {32, 10},
    preloadVars = {
        {var = "foundMultiple", desc = "foundMultiple очищается перед проверкой"},
    },
    instruction = [=[
<h>Практика: while, break и остаток от деления</h>
<t>Создай глобальную переменную <k>foundMultiple</k>.</t>
<t>Найди первое число от 1 до 30, которое делится на 7 без остатка.</t>

<w>Важно:</w>
<t>Переменная <k>foundMultiple</k> должна содержать само найденное число, а не остаток от деления.</t>

<t>Ожидаемое значение:</t>
<s>7</s>

<t>Используй:</t>
<t>- цикл <k>while</k>;</t>
<t>- переменную <k>i</k>;</t>
<t>- остаток от деления <k>%</k>;</t>
<t>- условие;</t>
<t>- выход через <k>break</k>;</t>
<t>- увеличение <k>i</k> на 1.</t>

<h>Подсказка</h>
<t>Остаток от деления вычисляется оператором <k>%</k>.</t>
<t>Если <k>i % 7</k> равно <n>0</n>, значит число <k>i</k> делится на 7 без остатка.</t>

<code>
print(14 % 7) -- 0: остатка нет, число делится без остатка
print(15 % 7) -- 1: остаток есть, число не делится без остатка
</code>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "foundMultiple",
        "while",
        "do",
        "end",
        "if",
        "then",
        "%",
        "7",
        "break",
        "i%7==0",
        "foundMultiple=i",
        "i=i+1",
    },
    checkCode = function()
        return type(_G.foundMultiple) == "number"
            and _G.foundMultiple == 7
    end,
}

ns_llua['lua'][39] = {
    type = "commenttest",
    title = "Практика: ipairs и подсчёт с условием",
    helpModules = {31, 4, 17},
    preloadVars = {
        {var = "loot", desc = "loot очищается перед проверкой"},
        {var = "lootCount", desc = "lootCount очищается перед проверкой"},
    },
    instruction = [=[
<h>Практика: ipairs и подсчёт с условием</h>
<t>Создай глобальную таблицу <k>loot</k> с четырьмя строками по порядку:</t>
<t>"Меч", "Щит", "Зелье", "Свиток".</t>

<t>Создай глобальную переменную <k>lootCount</k>.</t>
<t>Посчитай количество предметов, которые НЕ равны "Щит".</t>

<t>Ожидаемое значение:</t>
<s>3</s>

<t>Используй:</t>
<t>- цикл <k>for</k>;</t>
<t>- <k>ipairs</k>;</t>
<t>- условие <k>if</k>;</t>
<t>- сравнение <k>~=</k>;</t>
<t>- увеличение <k>lootCount</k> на 1.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "loot",
        "lootCount",
        "for",
        "ipairs",
        "do",
        "end",
        "if",
        "then",
        "~=",
        "Щит",
        "lootCount=lootCount+1",
        "Меч",
        "Зелье",
        "Свиток",
    },
    checkCode = function()
        return type(_G.loot) == "table"
            and _G.loot[1] == "Меч"
            and _G.loot[2] == "Щит"
            and _G.loot[3] == "Зелье"
            and _G.loot[4] == "Свиток"
            and _G.lootCount == 3
    end,
}

ns_llua['lua'][40] = {
    type = "commenttest",
    title = "Практика: поиск в таблице и break",
    helpModules = {31, 4, 17, 19},
    preloadVars = {
        {var = "pouch", desc = "pouch очищается перед проверкой"},
        {var = "elixirIndex", desc = "elixirIndex очищается перед проверкой"},
    },
    instruction = [=[
<h>Практика: поиск в таблице и break</h>
<t>Создай глобальную таблицу <k>pouch</k> с четырьмя строками по порядку:</t>
<t>"Кинжал", "Эликсир", "Свиток", "Эликсир".</t>

<t>Создай глобальную переменную <k>elixirIndex</k>.</t>
<t>Найди индекс первого элемента "Эликсир" и сохрани его в <k>elixirIndex</k>.</t>

<t>Ожидаемое значение:</t>
<s>2</s>

<t>Используй:</t>
<t>- цикл <k>for</k>;</t>
<t>- <k>ipairs</k>;</t>
<t>- переменные <k>i</k> и <k>v</k>;</t>
<t>- условие <k>if</k>;</t>
<t>- выход из цикла через <k>break</k>.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "pouch",
        "elixirIndex",
        "for",
        "ipairs",
        "do",
        "end",
        "if",
        "then",
        "break",
        "Эликсир",
        "elixirIndex=i",
    },
    checkCode = function()
        return type(_G.pouch) == "table"
            and _G.pouch[1] == "Кинжал"
            and _G.pouch[2] == "Эликсир"
            and _G.pouch[3] == "Свиток"
            and _G.pouch[4] == "Эликсир"
            and _G.elixirIndex == 2
    end,
}

ns_llua['lua'][41] = {
    type = "commenttest",
    title = "Практика: обратный отсчёт",
    helpModules = {31, 7},
    preloadVars = {
        {var = "launchSequence", desc = "launchSequence очищается перед проверкой"},
    },
    instruction = [=[
<h>Практика: обратный отсчёт</h>
<t>Создай глобальную переменную <k>launchSequence</k>.</t>
<t>Собери строку обратного отсчёта от 5 до 1.</t>
<t>После цикла добавь в конец слово "СТАРТ!".</t>

<t>Ожидаемое значение:</t>
<s>"5... 4... 3... 2... 1... СТАРТ!"</s>

<t>Используй:</t>
<t>- цикл <k>for</k> от 5 до 1;</t>
<t>- шаг <k>-1</k>;</t>
<t>- конкатенацию;</t>
<t>- добавление финального слова после цикла.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "launchSequence",
        "for",
        "do",
        "end",
        "5",
        "1",
        "-1",
        "launchSequence=launchSequence..",
        "СТАРТ!",
    },
    checkCode = function()
        return type(_G.launchSequence) == "string"
            and _G.launchSequence == "5... 4... 3... 2... 1... СТАРТ!"
    end,
}

ns_llua['lua'][42] = {
    type = "commenttest",
    title = "Практика: поиск по подстроке через string.find",
    helpModules = {31, 33, 4, 7},
    preloadVars = {
        {var = "items", desc = "items очищается перед проверкой"},
        {var = "found", desc = "found очищается перед проверкой"},
    },
    instruction = [=[
<h>Практика: поиск по подстроке через string.find</h>
<t>Создай глобальную таблицу <k>items</k> с пятью строками по порядку:</t>
<t>"Меч", "Молот", "Кольцо", "Щит", "Плащ".</t>

<t>Создай глобальную переменную <k>found</k>.</t>
<t>Найди все предметы, в которых есть подстрока "ол".</t>
<t>Собери их названия в строку через пробел.</t>
<t>В конце строки тоже должен быть пробел.</t>

<t>Ожидаемое значение:</t>
<s>"Молот Кольцо "</s>

<t>Используй:</t>
<t>- цикл <k>for</k>;</t>
<t>- <k>ipairs</k>;</t>
<t>- <k>string.find</k>;</t>
<t>- условие <k>if</k>;</t>
<t>- конкатенацию.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "items",
        "found",
        "for",
        "ipairs",
        "do",
        "end",
        "string.find",
        "if",
        "then",
        "ол",
        "found=found..",
        "Меч",
        "Молот",
        "Кольцо",
        "Щит",
        "Плащ",
    },
    checkCode = function()
        return type(_G.items) == "table"
            and _G.items[1] == "Меч"
            and _G.items[2] == "Молот"
            and _G.items[3] == "Кольцо"
            and _G.items[4] == "Щит"
            and _G.items[5] == "Плащ"
            and _G.found == "Молот Кольцо "
    end,
}

ns_llua['lua'][43] = {
    type = "commenttest",
    title = "Итоговый комбо-тест: циклы, tonumber, if и string.format",
    helpModules = {31, 32, 33, 4, 7, 10, 17, 19},
    preloadVars = {
        {var = "goldStrings", desc = "goldStrings очищается перед проверкой"},
        {var = "bigGoldCount", desc = "bigGoldCount очищается перед проверкой"},
        {var = "bigGoldSum", desc = "bigGoldSum очищается перед проверкой"},
        {var = "bigGoldReport", desc = "bigGoldReport очищается перед проверкой"},
    },
    instruction = [=[
<h>Итоговый комбо-тест</h>
<t>Создай глобальную таблицу <k>goldStrings</k> с тремя строками:</t>
<t>"1200", "850", "2000".</t>

<t>Создай глобальные переменные:</t>
<t><k>bigGoldCount</k> — количество сумм, которые больше или равны 1000;</t>
<t><k>bigGoldSum</k> — сумма таких значений;</t>
<t><k>bigGoldReport</k> — итоговый отчёт.</t>

<t>Пройди по таблице <k>goldStrings</k> циклом <k>ipairs</k>.</t>
<t>Каждую строку преобразуй в число через <k>tonumber</k>.</t>
<t>Если число больше или равно 1000, увеличь <k>bigGoldCount</k> на 1 и прибавь число к <k>bigGoldSum</k>.</t>

<t>После цикла создай <k>bigGoldReport</k> через <k>string.format</k> по шаблону:</t>
<s>"Крупных сумм: %d, всего: %d"</s>

<t>Ожидаемые значения:</t>
<s>bigGoldCount = 2</s>
<s>bigGoldSum = 3200</s>
<s>bigGoldReport = "Крупных сумм: 2, всего: 3200"</s>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "goldStrings",
        "bigGoldCount",
        "bigGoldSum",
        "bigGoldReport",
        "for",
        "ipairs",
        "do",
        "end",
        "tonumber",
        "if",
        "then",
        ">=",
        "1000",
        "string.format",
        "bigGoldCount=bigGoldCount+1",
        "bigGoldSum=bigGoldSum+",
        '"1200"',
        '"850"',
        '"2000"',
    },
    checkCode = function()
        return type(_G.goldStrings) == "table"
            and _G.goldStrings[1] == "1200"
            and _G.goldStrings[2] == "850"
            and _G.goldStrings[3] == "2000"
            and _G.bigGoldCount == 2
            and _G.bigGoldSum == 3200
            and _G.bigGoldReport == "Крупных сумм: 2, всего: 3200"
    end,
}

ns_llua['lua'][44] = {
    type = "info",
    title = "Хэш-таблицы и массивы",
    helpModules = {4},
    content = [=[
<h>Хэш-таблицы и массивы</h>
<t>В Lua таблица может работать и как массив, и как словарь.</t>
<t>Это не два разных типа данных. Это одна и та же <k>table</k>, которую используют по-разному.</t>

<h>Массив</h>
<t>Массив — это таблица с числовыми ключами подряд: 1, 2, 3 и так далее.</t>
<code>
local items = {"Меч", "Щит", "Зелье"} -- создаём список предметов
print(items[1]) -- выводим первый элемент: "Меч"
print(#items) -- выводим количество элементов: 3
</code>
<t>Массивы удобны, когда важен порядок элементов.</t>

<h>Хэш-таблица, или словарь</h>
<t>Хэш-таблица — это таблица, где ключами могут быть строки, числа и другие значения, кроме <k>nil</k>.</t>
<code>
local player = {name = "Артас", level = 80} -- создаём словарь
print(player.name) -- читаем поле name: "Артас"
print(player["level"]) -- читаем поле level: 80
</code>
<t>Хэш-таблицы удобны, когда данные имеют имена.</t>

<h>Чем массив отличается от хэш-таблицы</h>
<c>Массив:</c> доступ по номеру, порядок сохранён, можно использовать оператор <k>#</k>.
<c>Хэш-таблица:</c> доступ по имени или другому ключу, порядок через <k>pairs</k> не гарантирован, оператор <k>#</k> обычно не используют.

<h>Память</h>
<t>Массивная часть таблицы хранится компактно, поэтому списки обычно занимают меньше памяти.</t>
<t>Хэш-часть хранит ключи, значения и служебную информацию для быстрого поиска, поэтому словари обычно занимают больше памяти.</t>
<w>Вывод:</w> если данные можно хранить как список — лучше хранить как список. Словарь нужен, когда нужны именованные поля или быстрый поиск по ключу.

<h>Когда использовать хэш-таблицы</h>
<t>- нужно найти значение по имени;</t>
<t>- нужно хранить настройки;</t>
<t>- нужно сопоставить предмет и цену;</t>
<t>- нужно быстро проверить, есть ли ключ;</t>
<t>- нужно описать объект с полями.</t>

<h>Перебор</h>
<t>Для массивов используют <k>ipairs</k>:</t>
<code>
local items = {"Меч", "Щит"} -- список
for index, value in ipairs(items) do -- перебираем по порядку
    print(index, value) -- выводим номер и значение
end
</code>
<t>Для словарей используют <k>pairs</k>:</t>
<code>
local prices = {["Факел"] = 10, ["Компас"] = 100} -- словарь цен
for key, value in pairs(prices) do -- перебираем ключи и значения
    print(key, value) -- выводим ключ и значение
end
</code>
<w>Важно:</w> порядок обхода через <k>pairs</k> не гарантирован.
]=],
}

ns_llua['lua'][45] = {
    type = "info",
    title = "Функции",
    helpModules = {44},
    content = [=[
<h>Функции</h>
<t>Функция — это блок кода, который можно вызывать много раз.</t>
<t>Функции помогают не повторять один и тот же код и разбивать программу на маленькие понятные части.</t>

<h>Объявление функции</h>
<code>
local function sum(a, b) -- объявляем локальную функцию
    return a + b -- возвращаем результат
end
print(sum(2, 3)) -- вызываем функцию и выводим 5
</code>

<h>Аргументы</h>
<t>Функция может принимать значения внутри скобок.</t>
<code>
local function greet(name) -- функция принимает аргумент name
    return "Привет, " .. name -- возвращаем строку
end
print(greet("Артас")) -- выводим: Привет, Артас
</code>

<h>return</h>
<t>Оператор <k>return</k> возвращает значение из функции.</t>
<code>
local function isAdult(age) -- функция проверки возраста
    if age >= 18 then -- если возраст подходит
        return true -- возвращаем true
    end
    return false -- иначе возвращаем false
end
</code>

<h>Несколько возвращаемых значений</h>
<t>Некоторые функции WoW API возвращают сразу несколько значений.</t>
<code>
local className, classToken = UnitClass("player") -- получаем два значения от UnitClass
print(className) -- выводим название класса, например "Воин"
print(classToken) -- выводим код класса, например "WARRIOR"
</code>

<t>Здесь одна функция вернула сразу два результата:</t>
<t>- <k>className</k> — понятное название класса;</t>
<t>- <k>classToken</k> — технический код класса.</t>

<t>Если первое значение не нужно, вместо него ставят <k>_</k>.</t>
<code>
local _, classToken = UnitClass("player") -- получаем только второй результат
print(classToken) -- выводим код класса, например "WARRIOR"
</code>

<h>Локальные и глобальные функции</h>
<code>
local function localSum(a, b) -- локальная функция
    return a + b -- возвращает сумму
end
function globalSum(a, b) -- глобальная функция
    return a + b -- возвращает сумму
end
</code>
<t>Локальные функции обычно лучше: они не засоряют глобальную область видимости и работают быстрее.</t>
<w>Важно для курса:</w> если практическое задание просит создать функцию для проверки, делай её глобальной, чтобы система могла её вызвать.

<h>Досрочный return</h>
<t>Из функции можно выйти раньше времени.</t>
<code>
local function getPrice(list, key) -- функция получения цены
    if type(list) ~= "table" then return 0 end -- если список не таблица, возвращаем 0
    return list[key] or 0 -- если ключа нет, возвращаем 0
end
</code>

<h>Зачем выносить логику в функции</h>
<t>- код становится короче;</t>
<t>- логику можно проверить отдельно;</t>
<t>- одну функцию можно использовать с разными данными;</t>
<t>- проще искать ошибки.</t>
]=],
}

ns_llua['lua'][46] = {
    type = "commenttest",
    title = "Практика: функция sumStats",
    helpModules = {44, 45, 4},
    preloadVars = {
        {var = "sumStats", desc = "sumStats очищается перед проверкой"},
        {var = "checkError", desc = "checkError очищается перед проверкой"},
        {var = "test1", desc = "test1 очищается перед проверкой"},
        {var = "test2", desc = "test2 очищается перед проверкой"},
        {var = "test3", desc = "test3 очищается перед проверкой"},
        {var = "test4", desc = "test4 очищается перед проверкой"},
    },
    reportVars = {
        "checkError",
        "test1",
        "test2",
        "test3",
        "test4",
    },
    instruction = [=[
<h>Практика: функция sumStats</h>
<t>Создай только глобальную функцию <k>sumStats(stats)</k>.</t>

<t>Функция получает хэш-таблицу <k>stats</k>.</t>
<t>Значения в таблице могут быть числами и не числами.</t>
<t>Функция должна вернуть сумму только тех значений, у которых тип <k>number</k>.</t>

<t>Используй:</t>
<t>- <k>pairs</k>;</t>
<t>- <k>type</k>;</t>
<t>- <k>return</k>.</t>

<w>Важно:</w>
<t>Таблицу создавать не нужно.</t>
<t>Система сама подставит свои таблицы в твою функцию во время проверки.</t>

<t>После проверки в отчёте будет показано:</t>
<t>- какая таблица подавалась в функцию;</t>
<t>- какой результат вернула функция;</t>
<t>- какой результат ожидался.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Создай глобальную функцию sumStats(stats)
]=],
    requireKeywords = {
        "sumStats",
        "function",
        "pairs",
        "type",
        "return",
    },
    checkCode = function()
        local function formatValue(value)
            if type(value) == "string" then
                return '"' .. value .. '"'
            end

            return tostring(value)
        end

        local function serializeTable(t)
            local keys = {}

            for k in pairs(t) do
                table.insert(keys, k)
            end

            table.sort(keys, function(a, b)
                return tostring(a) < tostring(b)
            end)

            local parts = {}

            for _, k in ipairs(keys) do
                table.insert(parts, tostring(k) .. "=" .. formatValue(t[k]))
            end

            return "{" .. table.concat(parts, ", ") .. "}"
        end

        local function copyTable(t)
            local out = {}

            for k, v in pairs(t) do
                out[k] = v
            end

            return out
        end

        _G.checkError = nil
        _G.test1 = nil
        _G.test2 = nil
        _G.test3 = nil
        _G.test4 = nil

        if type(_G.sumStats) ~= "function" then
            _G.checkError = "sumStats не является глобальной функцией"
            return false
        end

        local tests = {
            {
                input = {
                    strength = 20,
                    agility = 15,
                    intellect = 30,
                },
                expected = 65,
            },
            {
                input = {
                    hp = 100,
                    name = "Герой",
                    stamina = 25,
                },
                expected = 125,
            },
            {
                input = {
                    one = 7,
                },
                expected = 7,
            },
            {
                input = {},
                expected = 0,
            },
        }

        local allOk = true

        for i, test in ipairs(tests) do
            local inputCopy = copyTable(test.input)
            local ok, result = pcall(_G.sumStats, test.input)

            local resultText

            if ok then
                resultText = formatValue(result)
            else
                resultText = "ошибка: " .. tostring(result)
            end

            _G["test" .. i] = "Таблица: "
                .. serializeTable(inputCopy)
                .. " | Результат: "
                .. resultText
                .. " | Ожидалось: "
                .. formatValue(test.expected)

            if not ok or result ~= test.expected then
                allOk = false
            end
        end

        return allOk
    end,
}

ns_llua['lua'][47] = {
    type = "commenttest",
    title = "Практика: чтение полей хэш-таблицы",
    helpModules = {44},
    preloadVars = {
        {var = "hero", value = {name = "Тралл", level = 60, ["класс"] = "Шаман"}, desc = "hero = {name = \"Тралл\", level = 60, [\"класс\"] = \"Шаман\"}"},
        {var = "key", value = "level", desc = "key = \"level\" (переменная с именем ключа)"},
        {var = "heroName", desc = "heroName очищается перед проверкой"},
        {var = "heroLevel", desc = "heroLevel очищается перед проверкой"},
        {var = "heroClass", desc = "heroClass очищается перед проверкой"},
        {var = "heroByKey", desc = "heroByKey очищается перед проверкой"},
    },
    reportVars = {"heroName", "heroLevel", "heroClass", "heroByKey", "hero", "key"},
    instruction = [=[
<h>Три способа обратиться к полю</h>
<c>hero.name</c> — ключ написан руками, только латиница. Ищет буквально "name".
<c>hero["name"]</c> — ключ написан руками в кавычках. То же самое, что точка, но работает и с кириллицей.
<c>hero[key]</c> — ключ берётся из переменной. Кавычек НЕТ. Ищет то, что лежит в key.

<w>Точка и ["строка"] ищут буквальный ключ. [переменная] подставляет значение переменной. Это разные вещи.</w>

<h>Ловушка</h>
<t>Если имя ключа лежит в переменной, точка не подойдёт:</t>
<c>hero.key</c> — ищет строку "key".
<c>hero[key]</c> — подставляет переменную key="level", ищет "level" = 60.

<h>Задание</h>
<t>Таблица <k>hero</k> и переменная <k>key</k> = "level" уже созданы. Прочитай поля четырьмя способами:</t>
<t>- <k>heroName</k> = поле name через точку;</t>
<t>- <k>heroLevel</k> = поле level через скобки со строкой;</t>
<t>- <k>heroClass</k> = поле класс через скобки со строкой (кириллица, точка тут запрещена);</t>
<t>- <k>heroByKey</k> = поле, имя которого в переменной key, через скобки с переменной (без кавычек).</t>
<t>В скобках со строкой используй двойные кавычки. Таблицу не создавай. Ничего не выводи.</t>
]=],
    initialCode = [=[
-- Прочитай поля таблицы hero четырьмя способами
]=],
    requireKeywords = {
        "heroName",
        "heroLevel",
        "heroClass",
        "heroByKey",
        "hero.name",
        'hero["level"]',
        'hero["класс"]',
        "hero[key]",
    },
    checkCode = function()
        return type(_G.heroName) == "string"
            and _G.heroName == "Тралл"
            and type(_G.heroLevel) == "number"
            and _G.heroLevel == 60
            and type(_G.heroClass) == "string"
            and _G.heroClass == "Шаман"
            and type(_G.heroByKey) == "number"
            and _G.heroByKey == 60
    end,
}

ns_llua['lua'][48] = {
    type = "commenttest",
    title = "Практика: запись полей хэш-таблицы",
    helpModules = {44},
    preloadVars = {
        {var = "item", value = {}, desc = "item = {} (пустая таблица)"},
    },
    reportVars = {"item"},
    instruction = [=[
<h>Практика: запись полей хэш-таблицы</h>
<t>Глобальная таблица <k>item</k> уже создана, пока она пустая.</t>

<t>Заполни её поля двумя разными способами:</t>
<t>- поле <k>name</k> запиши через точку, значение <s>"Меч"</s>;</t>
<t>- поле <k>quality</k> запиши через квадратные скобки, значение <s>"Эпический"</s>;</t>
<t>- поле <k>price</k> запиши через квадратные скобки, значение <n>100</n>;</t>
<t>- поле <k>stack</k> запиши через точку, значение <n>5</n>.</t>

<h>Подсказка по синтаксису</h>
<t>Запись через точку выглядит так: <c>имя.поле = значение</c></t>
<t>Запись через скобки выглядит так: <c>имя["поле"] = значение</c></t>
<w>Важно:</w> внутри квадратных скобок используй именно двойные кавычки.

<t>Таблицу создавать не нужно, она уже есть. Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Заполни поля таблицы item двумя способами
]=],
    requireKeywords = {
        "item.name",
        'item["quality"]',
        'item["price"]',
        "item.stack",
    },
    checkCode = function()
        return type(_G.item) == "table"
            and _G.item.name == "Меч"
            and _G.item.quality == "Эпический"
            and _G.item.price == 100
            and _G.item.stack == 5
    end,
}

ns_llua['lua'][49] = {
    type = "commenttest",
    title = "Практика: чтение и запись двумя способами",
    helpModules = {44, 47, 48},
    preloadVars = {
        {var = "source", value = {name = "Клинок", price = 100}, desc = "source = {name = \"Клинок\", price = 100}"},
        {var = "copy", desc = "copy очищается перед проверкой"},
    },
    reportVars = {"copy", "source"},
    instruction = [=[
<h>Практика: чтение и запись двумя способами</h>
<t>Глобальная таблица <k>source</k> уже создана. В ней поля <k>name</k> и <k>price</k>.</t>
<w>Важно:</w> таблицу <k>source</k> менять нельзя. Мы только читаем из неё.</t>

<t>Создай новую глобальную таблицу <k>copy</k> (пустую).</t>
<t>Скопируй в неё данные из <k>source</k> и добавь свои поля, используя оба синтаксиса и на чтение, и на запись:</t>
<t>- <k>copy.name</k> присвой значение <k>source.name</k> (чтение и запись через точку);</t>
<t>- <k>copy["price"]</k> присвой значение <k>source["price"]</k> (чтение и запись через скобки);</t>
<t>- добавь новое поле <k>copy["quality"]</k> со значением <s>"Редкий"</s> (запись через скобки);</t>
<t>- добавь новое поле <k>copy.stack</k> со значением <n>1</n> (запись через точку).</t>

<h>Подсказка по синтаксису</h>
<t>Через точку: <c>copy.name = source.name</c></t>
<t>Через скобки: <c>copy["price"] = source["price"]</c></t>
<w>Важно:</w> внутри квадратных скобок используй именно двойные кавычки.

<t>Смысл задания: оба способа работают с одними и теми же данными таблицы.</t>
<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Создай таблицу copy и заполни её двумя способами
]=],
    requireKeywords = {
        "copy",
        "copy.name",
        "source.name",
        'copy["price"]',
        'source["price"]',
        'copy["quality"]',
        "copy.stack",
    },
    checkCode = function()
        return type(_G.copy) == "table"
            and _G.copy.name == "Клинок"
            and _G.copy.price == 100
            and _G.copy.quality == "Редкий"
            and _G.copy.stack == 1
            and type(_G.source) == "table"
            and _G.source.name == "Клинок"
            and _G.source.price == 100
    end,
}

ns_llua['lua'][50] = {
    type = "commenttest",
    title = "Практика: функция countRareItems",
    helpModules = {44, 45, 31},
    preloadVars = {
        {var = "countRareItems", desc = "countRareItems очищается перед проверкой"},
        {var = "checkError", desc = "checkError очищается перед проверкой"},
        {var = "test1", desc = "test1 очищается перед проверкой"},
        {var = "test2", desc = "test2 очищается перед проверкой"},
        {var = "test3", desc = "test3 очищается перед проверкой"},
        {var = "test4", desc = "test4 очищается перед проверкой"},
    },
    reportVars = {
        "checkError",
        "test1",
        "test2",
        "test3",
        "test4",
    },
    instruction = [=[
<h>Практика: функция countRareItems</h>
<t>Создай только глобальную функцию <k>countRareItems(items)</k>.</t>

<t>Функция получает массив таблиц. Каждый элемент массива — это маленький словарь с информацией о предмете.</t>
<t>У предмета может быть поле <k>rare</k> со значением <k>true</k> или <k>false</k> (или его может не быть вовсе).</t>
<t>Функция должна вернуть количество предметов, у которых <k>rare == true</k>.</t>

<t>Используй:</t>
<t>- <k>ipairs</k>;</t>
<t>- <k>if</k>;</t>
<t>- <k>return</k>.</t>

<w>Важно:</w>
<t>Таблицу создавать не нужно.</t>
<t>Система сама подставит свои массивы предметов в твою функцию во время проверки.</t>

<t>После проверки в отчёте будет показано:</t>
<t>- какой массив подавался в функцию;</t>
<t>- какой результат вернула функция;</t>
<t>- какой результат ожидался.</t>

<t>Ничего выводить не нужно.</t>
]=],
    initialCode = [=[
-- Создай глобальную функцию countRareItems(items)
]=],
    requireKeywords = {
        "countRareItems",
        "function",
        "ipairs",
        "return",
    },
    checkCode = function()
        local function isArray(t)
            local n = #t
            if n == 0 then
                for _ in pairs(t) do
                    return false
                end
                return true
            end

            local count = 0
            for k in pairs(t) do
                count = count + 1
                if type(k) ~= "number" or k < 1 or k > n or k ~= math.floor(k) then
                    return false
                end
            end

            return count == n
        end

        local function fmt(v, depth)
            depth = depth or 0
            local t = type(v)

            if t == "string" then
                return '"' .. v .. '"'
            elseif t == "number" or t == "boolean" then
                return tostring(v)
            elseif t == "nil" then
                return "nil"
            elseif t == "table" then
                if depth >= 2 then
                    return "{...}"
                end

                if isArray(v) then
                    local parts = {}
                    for i = 1, #v do
                        parts[i] = fmt(v[i], depth + 1)
                    end
                    return "{" .. table.concat(parts, ", ") .. "}"
                end

                local keys = {}
                for k in pairs(v) do
                    table.insert(keys, k)
                end
                table.sort(keys, function(a, b)
                    return tostring(a) < tostring(b)
                end)

                local parts = {}
                for _, k in ipairs(keys) do
                    local ks
                    if type(k) == "string" then
                        ks = '["' .. k .. '"]'
                    else
                        ks = "[" .. tostring(k) .. "]"
                    end
                    table.insert(parts, ks .. "=" .. fmt(v[k], depth + 1))
                end

                return "{" .. table.concat(parts, ", ") .. "}"
            end

            return "<" .. t .. ">"
        end

        _G.checkError = nil
        _G.test1 = nil
        _G.test2 = nil
        _G.test3 = nil
        _G.test4 = nil

        if type(_G.countRareItems) ~= "function" then
            _G.checkError = "countRareItems не является глобальной функцией"
            return false
        end

        local tests = {
            {
                input = {{rare = true}, {rare = false}, {rare = true}, {}},
                expected = 2,
            },
            {
                input = {},
                expected = 0,
            },
            {
                input = {{rare = false}, {rare = false}},
                expected = 0,
            },
            {
                input = {{rare = true}},
                expected = 1,
            },
        }

        local allOk = true

        for i, test in ipairs(tests) do
            local inputText = fmt(test.input)
            local ok, result = pcall(_G.countRareItems, test.input)

            local resultText
            if ok then
                resultText = fmt(result)
            else
                resultText = "ошибка: " .. tostring(result)
            end

            _G["test" .. i] = "Массив: "
                .. inputText
                .. " | Результат: "
                .. resultText
                .. " | Ожидалось: "
                .. fmt(test.expected)

            if not ok or result ~= test.expected then
                allOk = false
            end
        end

        return allOk
    end,
}

ns_llua['lua'][51] = {
    type = "commenttest",
    title = "Практика: функция countItemsByQuality",
    helpModules = {44, 45, 33},
    preloadVars = {
        {var = "countItemsByQuality", desc = "countItemsByQuality очищается перед проверкой"},
        {var = "checkError", desc = "checkError очищается перед проверкой"},
        {var = "test1", desc = "test1 очищается перед проверкой"},
        {var = "test2", desc = "test2 очищается перед проверкой"},
        {var = "test3", desc = "test3 очищается перед проверкой"},
        {var = "test4", desc = "test4 очищается перед проверкой"},
    },
    reportVars = {
        "checkError",
        "test1",
        "test2",
        "test3",
        "test4",
    },
    instruction = [=[
<h>Практика: функция countItemsByQuality</h>
<t>Создай только глобальную функцию <k>countItemsByQuality(items, qualityText)</k>.</t>

<t>Функция получает хэш-таблицу <k>items</k>, где ключ — название предмета, а значение — строка с качеством.</t>
<t>Вторым аргументом идёт строка <k>qualityText</k>.</t>
<t>Функция должна вернуть количество предметов, качество которых содержит подстроку <k>qualityText</k>.</t>

<t>Используй:</t>
<t>- <k>pairs</k>;</t>
<t>- <k>string.find</k>;</t>
<t>- <k>return</k>.</t>

]=],
    initialCode = [=[
-- Создай глобальную функцию countItemsByQuality(items, qualityText)
]=],
    requireKeywords = {
        "countItemsByQuality",
        "function",
        "pairs",
        "string.find",
        "return",
    },
    checkCode = function()
        local function isArray(t)
            local n = #t
            if n == 0 then
                for _ in pairs(t) do
                    return false
                end
                return true
            end

            local count = 0
            for k in pairs(t) do
                count = count + 1
                if type(k) ~= "number" or k < 1 or k > n or k ~= math.floor(k) then
                    return false
                end
            end

            return count == n
        end

        local function fmt(v, depth)
            depth = depth or 0
            local t = type(v)

            if t == "string" then
                return '"' .. v .. '"'
            elseif t == "number" or t == "boolean" then
                return tostring(v)
            elseif t == "nil" then
                return "nil"
            elseif t == "table" then
                if depth >= 2 then
                    return "{...}"
                end

                if isArray(v) then
                    local parts = {}
                    for i = 1, #v do
                        parts[i] = fmt(v[i], depth + 1)
                    end
                    return "{" .. table.concat(parts, ", ") .. "}"
                end

                local keys = {}
                for k in pairs(v) do
                    table.insert(keys, k)
                end
                table.sort(keys, function(a, b)
                    return tostring(a) < tostring(b)
                end)

                local parts = {}
                for _, k in ipairs(keys) do
                    local ks
                    if type(k) == "string" then
                        ks = '["' .. k .. '"]'
                    else
                        ks = "[" .. tostring(k) .. "]"
                    end
                    table.insert(parts, ks .. "=" .. fmt(v[k], depth + 1))
                end

                return "{" .. table.concat(parts, ", ") .. "}"
            end

            return "<" .. t .. ">"
        end

        _G.checkError = nil
        _G.test1 = nil
        _G.test2 = nil
        _G.test3 = nil
        _G.test4 = nil

        if type(_G.countItemsByQuality) ~= "function" then
            _G.checkError = "countItemsByQuality не является глобальной функцией"
            return false
        end

        local tests = {
            {
                input = {{a = "Редкий", b = "Обычный", c = "Редкость"}, "Ред"},
                expected = 2,
            },
            {
                input = {{}, "Ред"},
                expected = 0,
            },
            {
                input = {{x = "Обычный", y = "Обычный"}, "Ред"},
                expected = 0,
            },
            {
                input = {{a = "Редкий"}, "Редкий"},
                expected = 1,
            },
        }

        local allOk = true

        for i, test in ipairs(tests) do
            local inputText = fmt(test.input[1]) .. ", " .. fmt(test.input[2])
            local ok, result = pcall(_G.countItemsByQuality, test.input[1], test.input[2])

            local resultText
            if ok then
                resultText = fmt(result)
            else
                resultText = "ошибка: " .. tostring(result)
            end

            _G["test" .. i] = "Аргументы: "
                .. inputText
                .. " | Результат: "
                .. resultText
                .. " | Ожидалось: "
                .. fmt(test.expected)

            if not ok or result ~= test.expected then
                allOk = false
            end
        end

        return allOk
    end,
}

ns_llua['lua'][52] = {
    type = "commenttest",
    title = "Итоговый комбо-тест: функция calculateTotalPrice",
    helpModules = {44, 45, 31, 33, 10},
    preloadVars = {
        {var = "calculateTotalPrice", desc = "calculateTotalPrice очищается перед проверкой"},
        {var = "checkError", desc = "checkError очищается перед проверкой"},
        {var = "test1", desc = "test1 очищается перед проверкой"},
        {var = "test2", desc = "test2 очищается перед проверкой"},
        {var = "test3", desc = "test3 очищается перед проверкой"},
        {var = "test4", desc = "test4 очищается перед проверкой"},
    },
    reportVars = {
        "checkError",
        "test1",
        "test2",
        "test3",
        "test4",
    },
    instruction = [=[
<h>Практика: функция calculateTotalPrice</h>
<t>Создай глобальную функцию <k>calculateTotalPrice(priceList, cart)</k>.</t>
<t><k>priceList</k> — таблица цен (ключ = название, значение = цена числом или строкой).</t>
<t><k>cart</k> — массив названий выбранных предметов.</t>
<t>Функция возвращает общую стоимость корзины.</t>
<t>Предмета нет в <k>priceList</k> — не считай его.</t>
<t>Цена строкой — преобразуй через <k>tonumber</k>.</t>
<t><k>tonumber</k> дал <k>nil</k> — не считай эту цену.</t>
<t>Таблицы создавать не надо — система подставит свои и покажет результат в отчёте.</t>
]=],
    initialCode = [=[
-- Создай глобальную функцию calculateTotalPrice(priceList, cart)
]=],
    requireKeywords = {
        "calculateTotalPrice",
        "function",
        "for",
        "tonumber",
        "return",
    },
    checkCode = function()
        local function isArray(t)
            local n = #t
            if n == 0 then
                for _ in pairs(t) do
                    return false
                end
                return true
            end

            local count = 0
            for k in pairs(t) do
                count = count + 1
                if type(k) ~= "number" or k < 1 or k > n or k ~= math.floor(k) then
                    return false
                end
            end

            return count == n
        end

        local function fmt(v, depth)
            depth = depth or 0
            local t = type(v)

            if t == "string" then
                return '"' .. v .. '"'
            elseif t == "number" or t == "boolean" then
                return tostring(v)
            elseif t == "nil" then
                return "nil"
            elseif t == "table" then
                if depth >= 2 then
                    return "{...}"
                end

                if isArray(v) then
                    local parts = {}
                    for i = 1, #v do
                        parts[i] = fmt(v[i], depth + 1)
                    end
                    return "{" .. table.concat(parts, ", ") .. "}"
                end

                local keys = {}
                for k in pairs(v) do
                    table.insert(keys, k)
                end
                table.sort(keys, function(a, b)
                    return tostring(a) < tostring(b)
                end)

                local parts = {}
                for _, k in ipairs(keys) do
                    local ks
                    if type(k) == "string" then
                        ks = '["' .. k .. '"]'
                    else
                        ks = "[" .. tostring(k) .. "]"
                    end
                    table.insert(parts, ks .. "=" .. fmt(v[k], depth + 1))
                end

                return "{" .. table.concat(parts, ", ") .. "}"
            end

            return "<" .. t .. ">"
        end

        _G.checkError = nil
        _G.test1 = nil
        _G.test2 = nil
        _G.test3 = nil
        _G.test4 = nil

        if type(_G.calculateTotalPrice) ~= "function" then
            _G.checkError = "calculateTotalPrice не является глобальной функцией"
            return false
        end

        local tests = {
            {
                input = {{["X"] = "5", ["Y"] = 7, ["Z"] = "bad"}, {"X", "Y", "Z", "W"}},
                expected = 12,
            },
            {
                input = {{}, {"A"}},
                expected = 0,
            },
            {
                input = {{["A"] = "10"}, {}},
                expected = 0,
            },
            {
                input = {{["A"] = "abc"}, {"A"}},
                expected = 0,
            },
        }

        local allOk = true

        for i, test in ipairs(tests) do
            local inputText = fmt(test.input[1]) .. ", " .. fmt(test.input[2])
            local ok, result = pcall(_G.calculateTotalPrice, test.input[1], test.input[2])

            local resultText
            if ok then
                resultText = fmt(result)
            else
                resultText = "ошибка: " .. tostring(result)
            end

            _G["test" .. i] = "Аргументы: "
                .. inputText
                .. " | Результат: "
                .. resultText
                .. " | Ожидалось: "
                .. fmt(test.expected)

            if not ok or result ~= test.expected then
                allOk = false
            end
        end

        return allOk
    end,
}

-- ============================================================
-- UI CLASS: MAIN WINDOW + HELP WINDOW + EDITOR
-- ============================================================

local UI = {}
UI.__index = UI

local TEXT_TAGS = {
    h  = "|cFFFFD700",
    k  = "|cFF80FF80",
    c  = "|cFF66CCFF",
    s  = "|cFFFF8080",
    n  = "|cFFFFB830",
    o  = "|cFFCC88FF",
    t  = "|cFFB3B3B3",
    w  = "|cFFFF8080",
    ok = "|cFF00FF00",
}

local CODE_TAGS = {
    kw = "|cFF80FF80",
    cm = "|cFF808080",
    st = "|cFFFF8080",
    nu = "|cFFFFB830",
    op = "|cFFCC88FF",
}

local function trim(s)
    return (s:match("^%s*(.-)%s*$"))
end

local function applyTags(text, tags, closeColor)
    for tag, color in pairs(tags) do
        text = text:gsub("<" .. tag .. ">", color)
        text = text:gsub("</" .. tag .. ">", closeColor)
    end
    return text
end

local function escapePipes(s)
    return (s:gsub("|", "||"))
end

local LUA_KEYWORDS = {
    ["and"] = true,
    ["break"] = true,
    ["do"] = true,
    ["else"] = true,
    ["elseif"] = true,
    ["end"] = true,
    ["false"] = true,
    ["for"] = true,
    ["function"] = true,
    ["if"] = true,
    ["in"] = true,
    ["local"] = true,
    ["nil"] = true,
    ["not"] = true,
    ["or"] = true,
    ["repeat"] = true,
    ["return"] = true,
    ["then"] = true,
    ["true"] = true,
    ["until"] = true,
    ["while"] = true,

    ["print"] = true,
    ["string"] = true,
    ["table"] = true,
    ["math"] = true,
    ["pairs"] = true,
    ["ipairs"] = true,
    ["type"] = true,
    ["tostring"] = true,
    ["tonumber"] = true,
    ["select"] = true,
    ["unpack"] = true,
    ["pcall"] = true,
    ["loadstring"] = true,
}

local function highlightLuaCode(code)
    if type(code) ~= "string" or code == "" then
        return ""
    end

    local out = {}
    local i = 1
    local n = #code

    local DEFAULT  = "|cFF66CCFF"
    local KEYWORD  = "|cFF80FF80"
    local COMMENT  = "|cFF808080"
    local STRING   = "|cFFFF8080"
    local NUMBER   = "|cFFFFB830"
    local OPERATOR = "|cFFCC88FF"
    local RESET    = "|r"

    table.insert(out, DEFAULT)

    while i <= n do
        local c = code:sub(i, i)

        if c == "-" and code:sub(i + 1, i + 1) == "-" then
            local j

            if code:sub(i + 2, i + 3) == "[[" then
                local close = code:find("]]", i + 4, true)
                j = close and (close + 2) or (n + 1)
            else
                local nl = code:find("[\r\n]", i)
                j = nl or (n + 1)
            end

            local token = code:sub(i, j - 1)
            table.insert(out, COMMENT .. escapePipes(token) .. RESET .. DEFAULT)
            i = j

        elseif c == '"' or c == "'" then
            local quote = c
            local j = i + 1

            while j <= n do
                local ch = code:sub(j, j)

                if ch == "\\" then
                    j = j + 2
                elseif ch == quote then
                    j = j + 1
                    break
                else
                    j = j + 1
                end
            end

            local token = code:sub(i, j - 1)
            table.insert(out, STRING .. escapePipes(token) .. RESET .. DEFAULT)
            i = j

        elseif c == "[" and code:sub(i + 1, i + 1) == "[" then
            local close = code:find("]]", i + 2, true)
            local j = close and (close + 2) or (n + 1)

            local token = code:sub(i, j - 1)
            table.insert(out, STRING .. escapePipes(token) .. RESET .. DEFAULT)
            i = j

        elseif c:match("%d") or (c == "." and code:sub(i + 1, i + 1):match("%d")) then
            local num = code:match("^%d+%.%d+", i)
                or code:match("^%d+", i)
                or code:match("^%.%d+", i)
                or c

            table.insert(out, NUMBER .. escapePipes(num) .. RESET .. DEFAULT)
            i = i + #num

        elseif c:match("[%a_]") then
            local word = code:match("^[%a_][%w_]*", i)

            if LUA_KEYWORDS[word] then
                table.insert(out, KEYWORD .. escapePipes(word) .. RESET .. DEFAULT)
            else
                table.insert(out, escapePipes(word))
            end

            i = i + #word

        elseif c:match("[%p]") then
            table.insert(out, OPERATOR .. escapePipes(c) .. RESET .. DEFAULT)
            i = i + 1

        else
            table.insert(out, escapePipes(c))
            i = i + 1
        end
    end

    table.insert(out, RESET)

    return table.concat(out)
end

local function hasManualCodeTags(text)
    return text:find("<kw>", 1, true)
        or text:find("<cm>", 1, true)
        or text:find("<st>", 1, true)
        or text:find("<nu>", 1, true)
        or text:find("<op>", 1, true)
end

local function markupText(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    text = escapePipes(text)
    return "|cFFFFFFFF" .. applyTags(text, TEXT_TAGS, "|cFFFFFFFF") .. "|r"
end

local function markupPlain(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    return "|cFFFFFFFF" .. escapePipes(text) .. "|r"
end

local function markupCode(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    if hasManualCodeTags(text) then
        text = escapePipes(text)
        return "|cFF66CCFF" .. applyTags(text, CODE_TAGS, "|cFF66CCFF") .. "|r"
    end

    return highlightLuaCode(text)
end

local function parseContent(raw)
    local blocks = {}

    if type(raw) ~= "string" or raw == "" then
        return blocks
    end

    local pos = 1

    while true do
        local startPos, endPos, codeText = raw:find("<code>(.-)</code>", pos)
        local textPart = trim(startPos and raw:sub(pos, startPos - 1) or raw:sub(pos))

        if textPart ~= "" then
            table.insert(blocks, { type = "text", content = textPart })
        end

        if not startPos then
            break
        end

        table.insert(blocks, { type = "code", content = trim(codeText) })
        pos = endPos + 1
    end

    return blocks
end

local function clearBlocks(blocks)
    for _, block in ipairs(blocks or {}) do
        block:Hide()
        block:SetParent(nil)
    end
end

local function updateScroll(scrollFrame, content, bar)
    local maxScroll = math.max(0, content:GetHeight() - (scrollFrame:GetHeight() or 1))

    bar:SetMinMaxValues(0, maxScroll)

    local value = bar:GetValue()

    if value > maxScroll then
        value = maxScroll
    end

    if value < 0 then
        value = 0
    end

    if value ~= bar:GetValue() then
        bar:SetValue(value)
    end

    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, value)
end

local function resetScroll(scrollFrame, content, bar)
    if not scrollFrame or not content or not bar then
        return
    end

    bar:SetValue(0)

    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
end

local function layoutBlocks(blocks, parent, scrollFrame, bar)
    local width = parent:GetWidth() or 560
    local y = -5

    local function layoutEditor(block)
        local editWidth = math.max(10, width - 20)
        local innerY = -10

        block:ClearAllPoints()
        block:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
        block:SetWidth(width)

        block._editBox:ClearAllPoints()
        block._editBox:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        block._editBox:SetWidth(editWidth)

        block._measure:ClearAllPoints()
        block._measure:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        block._measure:SetWidth(editWidth)
        block._measure:SetText(block._editBox:GetText() or "")

        local editHeight = math.max(60, (block._measure:GetStringHeight() or 0) + 12)
        block._editBox:SetHeight(editHeight)
        innerY = innerY - editHeight - 8

        block._button:ClearAllPoints()
        block._button:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        innerY = innerY - (block._button:GetHeight() or 22) - 12

        block._previewLabel:ClearAllPoints()
        block._previewLabel:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        innerY = innerY - (block._previewLabel:GetStringHeight() or 12) - 4

        block._preview:ClearAllPoints()
        block._preview:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        block._preview:SetWidth(editWidth)

        local previewHeight = math.max(16, (block._preview:GetStringHeight() or 0) + 4)
        innerY = innerY - previewHeight - 12

        if block._resultMessage:GetText() and block._resultMessage:GetText() ~= "" then
            block._resultMessage:ClearAllPoints()
            block._resultMessage:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
            block._resultMessage:SetWidth(editWidth)
            innerY = innerY - (block._resultMessage:GetStringHeight() or 0) - 10
        else
            block._resultMessage:ClearAllPoints()
        end

        local function layoutResultLine(label, text)
            if text:GetText() and text:GetText() ~= "" then
                label:ClearAllPoints()
                label:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
                innerY = innerY - (label:GetStringHeight() or 12) - 2

                text:ClearAllPoints()
                text:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
                text:SetWidth(editWidth)
                innerY = innerY - (text:GetStringHeight() or 0) - 10
            else
                label:ClearAllPoints()
                text:ClearAllPoints()
            end
        end

        layoutResultLine(block._expectedLabel, block._expectedText)
        layoutResultLine(block._currentLabel, block._currentText)

        block:SetHeight(math.max(120, -innerY + 10))
        y = y - block:GetHeight() - 8
    end

    for _, block in ipairs(blocks or {}) do
        if block._kind == "editor" then
            layoutEditor(block)
        else
            block:ClearAllPoints()
            block:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
            block:SetWidth(width)

            local fs = block._fs

            if block._kind == "code" then
                fs:SetWidth(math.max(10, width - 24))
                block:SetHeight(math.max(20, (fs:GetStringHeight() or 0) + 16))
            else
                fs:SetWidth(math.max(10, width - 10))
                block:SetHeight(math.max(18, (fs:GetStringHeight() or 0) + 4))
            end

            y = y - block:GetHeight() - 8
        end
    end

    parent:SetHeight(math.max(100, -y + 5))
    updateScroll(scrollFrame, parent, bar)
end

local function createTextBlock(parent, raw)
    local block = CreateFrame("Frame", nil, parent)

    local fs = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("TOPLEFT", 5, 0)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetNonSpaceWrap(true)
    fs:SetSpacing(3)
    fs:SetText(markupText(raw))

    block._fs = fs
    block._kind = "text"

    return block
end

local function createCodeBlock(parent, raw)
    local block = CreateFrame("Frame", nil, parent)

    local bg = block:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(block)
    bg:SetTexture(0.03, 0.04, 0.07, 1)

    local bar = block:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT")
    bar:SetPoint("BOTTOMLEFT")
    bar:SetWidth(3)
    bar:SetTexture(0.35, 0.55, 0.95, 1)

    local fs = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("TOPLEFT", 12, -8)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetNonSpaceWrap(true)
    fs:SetSpacing(2)
    fs:SetText(markupCode(raw))

    block._fs = fs
    block._kind = "code"

    return block
end

local editorCounter = 0

local function createEditorBlock(parent, data, ui)
    editorCounter = editorCounter + 1

    local block = CreateFrame("Frame", nil, parent)
    block._kind = "editor"
    block._name = data.name or ("editor" .. editorCounter)

    local bg = block:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(block)
    bg:SetTexture(0.03, 0.04, 0.07, 1)

    local bar = block:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT")
    bar:SetPoint("BOTTOMLEFT")
    bar:SetWidth(3)
    bar:SetTexture(0.35, 0.55, 0.95, 1)

    local editBox = CreateFrame("EditBox", nil, block)
    editBox:SetFontObject("GameFontNormal")
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetJustifyH("LEFT")
    editBox:SetText(data.code or "")

    local button = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
    button:SetSize(130, 22)
    button:SetText(data.buttonText or "Выполнить")

    local previewLabel = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewLabel:SetText("|cFFB3B3B3Подсветка кода:|r")

    local preview = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    preview:SetJustifyH("LEFT")
    preview:SetJustifyV("TOP")
    preview:SetNonSpaceWrap(true)
    preview:SetSpacing(2)
    preview:SetText(markupCode(data.code or ""))

    local resultMessage = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resultMessage:SetJustifyH("LEFT")
    resultMessage:SetJustifyV("TOP")
    resultMessage:SetNonSpaceWrap(true)
    resultMessage:SetSpacing(2)
    resultMessage:SetText("")

    local expectedLabel = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    expectedLabel:SetJustifyH("LEFT")
    expectedLabel:SetText("")

    local expectedText = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    expectedText:SetJustifyH("LEFT")
    expectedText:SetJustifyV("TOP")
    expectedText:SetNonSpaceWrap(true)
    expectedText:SetSpacing(2)
    expectedText:SetText("")

    local currentLabel = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetJustifyH("LEFT")
    currentLabel:SetText("")

    local currentText = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentText:SetJustifyH("LEFT")
    currentText:SetJustifyV("TOP")
    currentText:SetNonSpaceWrap(true)
    currentText:SetSpacing(2)
    currentText:SetText("")

    local measure = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    measure:SetJustifyH("LEFT")
    measure:SetJustifyV("TOP")
    measure:SetNonSpaceWrap(true)
    measure:SetAlpha(0)

    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    editBox:SetScript("OnTabPressed", function(self)
        self:Insert("    ")
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        if IsControlKeyDown and IsControlKeyDown() then
            button:Click()
        else
            self:Insert("\n")
        end
    end)

    editBox:SetScript("OnTextChanged", function(self)
        preview:SetText(markupCode(self:GetText() or ""))

        if ui then
            ui.layoutDirty = true
        end
    end)

    button:SetScript("OnClick", function()
        editBox:ClearFocus()

        if ui and ui.callbacks and ui.callbacks.onExecute then
            ui.callbacks.onExecute(block._name, editBox:GetText() or "")
        end
    end)

    block._editBox = editBox
    block._button = button
    block._preview = preview
    block._previewLabel = previewLabel
    block._resultMessage = resultMessage
    block._expectedLabel = expectedLabel
    block._expectedText = expectedText
    block._currentLabel = currentLabel
    block._currentText = currentText
    block._measure = measure

    return block
end

local function addBackgroundBorder(frame)
    local border = frame:CreateTexture(nil, "BACKGROUND")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    border:SetTexture(0.25, 0.25, 0.35, 1)

    local bg = frame:CreateTexture(nil, "BORDER")
    bg:SetAllPoints(frame)
    bg:SetTexture(0.08, 0.08, 0.12, 0.97)
end

local function createScrollArea(parent, contentWidth, topX, topY, bottomX, bottomY)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
    scrollFrame:SetPoint("TOPLEFT", topX, topY)
    scrollFrame:SetPoint("BOTTOMRIGHT", bottomX, bottomY)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(contentWidth)
    content:SetHeight(100)
    content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    scrollFrame:SetScrollChild(content)

    local bar = CreateFrame("Slider", nil, parent)
    bar:SetPoint("TOPRIGHT", -8, topY - 5)
    bar:SetPoint("BOTTOMRIGHT", -8, bottomY + 3)
    bar:SetWidth(16)
    bar:SetOrientation("VERTICAL")
    bar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    bar:SetMinMaxValues(0, 0)
    bar:SetValueStep(1)
    bar:SetValue(0)

    local scrollBg = bar:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints(bar)
    scrollBg:SetTexture(0.15, 0.15, 0.20, 1)

    bar:SetScript("OnValueChanged", function(_, value)
        content:ClearAllPoints()
        content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, value)
    end)

    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(_, delta)
        local maxScroll = select(2, bar:GetMinMaxValues())
        local value = math.max(0, math.min(bar:GetValue() - delta * 25, maxScroll))
        bar:SetValue(value)
    end)

    return scrollFrame, content, bar
end

local function setButtonEnabled(button, enabled)
    if enabled then
        button:Enable()
        button:SetAlpha(1)
    else
        button:Disable()
        button:SetAlpha(0.45)
    end
end

function UI:new(parent)
    local self = setmetatable({}, UI)

    self.parent = parent or UIParent
    self.callbacks = {}
    self.helpModules = nil
    self.helpKey = nil

    self.blocks = {}
    self.helpBlocks = {}
    self.editors = {}

    self.layoutDirty = false
    self.isScaling = false
    self.scaleStartScale = 1
    self.scaleStartX = 0
    self.scaleStartY = 0

    self:_CreateMain()

    return self
end

function UI:SaveState()
    if not self.frame then
        return
    end

    nsDbc = nsDbc or {}
    nsDbc.luaTest = nsDbc.luaTest or {}

    local point, relativeTo, relativePoint, x, y = self.frame:GetPoint(1)

    nsDbc.luaTest.windowState = {
        point = point or "CENTER",
        relativeTo = (relativeTo and relativeTo.GetName and relativeTo:GetName()) or "UIParent",
        relativePoint = relativePoint or "CENTER",
        x = x or 0,
        y = y or 0,
        scale = self.frame:GetScale() or 1,
    }
end

function UI:LoadState()
    if not self.frame then
        return
    end

    local state = nsDbc and nsDbc.luaTest and nsDbc.luaTest.windowState

    if type(state) ~= "table" then
        return
    end

    local scale = tonumber(state.scale)

    if scale then
        scale = math.max(0.75, math.min(2.0, scale))
        self.frame:SetScale(scale)
    end

    local point = tostring(state.point or "CENTER")
    local relativePoint = tostring(state.relativePoint or point)
    local relativeTo = _G[state.relativeTo or "UIParent"] or UIParent

    local x = tonumber(state.x) or tonumber(state.xOfs) or 0
    local y = tonumber(state.y) or tonumber(state.yOfs) or 0

    self.frame:ClearAllPoints()
    self.frame:SetPoint(point, relativeTo, relativePoint, x, y)
end

function UI:_CreateMain()
    local f = CreateFrame("Frame", nil, self.parent)

    f:SetSize(620, 450)
    f:SetPoint("CENTER")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")

    addBackgroundBorder(f)

    local titleBg = f:CreateTexture(nil, "ARTWORK")
    titleBg:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    titleBg:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    titleBg:SetHeight(35)
    titleBg:SetTexture(0.15, 0.15, 0.20, 1)

    local titleSeparator = f:CreateTexture(nil, "ARTWORK")
    titleSeparator:SetPoint("TOPLEFT", titleBg, "BOTTOMLEFT", 0, 0)
    titleSeparator:SetPoint("TOPRIGHT", titleBg, "BOTTOMRIGHT", 0, 0)
    titleSeparator:SetHeight(2)
    titleSeparator:SetTexture(0.30, 0.30, 0.50, 1)

    local bottomBg = f:CreateTexture(nil, "ARTWORK")
    bottomBg:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    bottomBg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    bottomBg:SetHeight(38)
    bottomBg:SetTexture(0.12, 0.12, 0.18, 1)

    local bottomSeparator = f:CreateTexture(nil, "ARTWORK")
    bottomSeparator:SetPoint("BOTTOMLEFT", bottomBg, "TOPLEFT", 0, 0)
    bottomSeparator:SetPoint("BOTTOMRIGHT", bottomBg, "TOPRIGHT", 0, 0)
    bottomSeparator:SetHeight(2)
    bottomSeparator:SetTexture(0.30, 0.30, 0.50, 1)

    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        self:HideHelp()

        if self.callbacks.onClose then
            self.callbacks.onClose()
        end

        f:Hide()
    end)

    local helpButton = CreateFrame("Button", nil, f)
    helpButton:SetSize(24, 24)
    helpButton:SetPoint("TOPRIGHT", -30, -5)

    local helpButtonText = helpButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    helpButtonText:SetAllPoints(helpButton)
    helpButtonText:SetText("?")
    helpButtonText:SetTextColor(0.8, 0.8, 0.2, 1)

    helpButton:SetScript("OnClick", function()
        if self.callbacks.onHelp then
            self.callbacks.onHelp(self.helpModules)
        end
    end)

    self.helpButton = helpButton

    self.titleText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.titleText:SetPoint("LEFT", f, "LEFT", 15, 0)
    self.titleText:SetPoint("RIGHT", helpButton, "LEFT", -8, 0)
    self.titleText:SetPoint("TOP", titleBg, "TOP", 0, -8)
    self.titleText:SetJustifyH("LEFT")

    self.scrollFrame, self.contentFrame, self.scrollBar = createScrollArea(f, 560, 18, -45, -28, 45)

    self.moduleText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.moduleText:SetPoint("BOTTOM", f, "BOTTOM", 0, 14)
    self.moduleText:SetTextColor(0.6, 0.6, 0.7, 1)

    self.prevButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    self.prevButton:SetSize(110, 24)
    self.prevButton:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 15, 8)
    self.prevButton:SetText("<  Назад")
    self.prevButton:SetScript("OnClick", function()
        if self.callbacks.onPrev then
            self.callbacks.onPrev()
        end
    end)

    self.nextButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    self.nextButton:SetSize(110, 24)
    self.nextButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -15, 8)
    self.nextButton:SetText("Вперед  >")
    self.nextButton:SetScript("OnClick", function()
        if self.callbacks.onNext then
            self.callbacks.onNext()
        end
    end)

    local scaleButton = CreateFrame("Button", nil, f)
    scaleButton:SetSize(18, 18)
    scaleButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3, 3)
    scaleButton:SetFrameLevel(f:GetFrameLevel() + 10)
    scaleButton:EnableMouse(true)

    local scaleTexture = scaleButton:CreateTexture(nil, "ARTWORK")
    scaleTexture:SetAllPoints(scaleButton)
    scaleTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

    scaleButton:SetScript("OnEnter", function()
        scaleTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    end)

    scaleButton:SetScript("OnLeave", function()
        scaleTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    end)

    scaleButton:RegisterForDrag("LeftButton")

    scaleButton:SetScript("OnDragStart", function()
        self.isScaling = true
        self.scaleStartScale = f:GetScale() or 1
        self.scaleStartX, self.scaleStartY = GetCursorPosition()
    end)

    scaleButton:SetScript("OnDragStop", function()
        self.isScaling = false
        self:SaveState()
    end)

    f:RegisterForDrag("LeftButton")

    f:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)

    f:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        self:SaveState()
    end)

    f:SetScript("OnUpdate", function()
        if self.layoutDirty then
            self.layoutDirty = false
            self:Layout()
        end

        if self.isScaling then
            local mx, my = GetCursorPosition()
            local dx = mx - self.scaleStartX
            local dy = my - self.scaleStartY

            local newScale = self.scaleStartScale + (dx - dy) / 1000
            newScale = math.max(0.75, math.min(2.0, newScale))

            local currentScale = f:GetScale() or 1

            if math.abs(newScale - currentScale) > 0.001 then
                f:SetScale(newScale)
            end
        end
    end)

    f:SetScript("OnShow", function()
        if not self.stateLoaded then
            self.stateLoaded = true
            self:LoadState()
        end

        self.layoutDirty = true
    end)

    self.frame = f

    self:LoadState()

    f:SetScript("OnHide", function()
        self.isScaling = false
        self:SaveState()
    end)

    f:Hide()
end

function UI:_CreateHelp()
    if self.helpFrame then
        return
    end

    local f = CreateFrame("Frame", nil, UIParent)

    f:SetSize(700, 580)
    f:SetPoint("CENTER", 40, 0)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("DIALOG")

    addBackgroundBorder(f)

    local titleBg = f:CreateTexture(nil, "ARTWORK")
    titleBg:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    titleBg:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    titleBg:SetHeight(30)
    titleBg:SetTexture(0.15, 0.15, 0.20, 1)

    local titleSeparator = f:CreateTexture(nil, "ARTWORK")
    titleSeparator:SetPoint("TOPLEFT", titleBg, "BOTTOMLEFT", 0, 0)
    titleSeparator:SetPoint("TOPRIGHT", titleBg, "BOTTOMRIGHT", 0, 0)
    titleSeparator:SetHeight(2)
    titleSeparator:SetTexture(0.30, 0.30, 0.50, 1)

    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        f:Hide()
    end)

    local titleText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", f, "LEFT", 15, 0)
    titleText:SetPoint("RIGHT", closeButton, "LEFT", -8, 0)
    titleText:SetPoint("TOP", titleBg, "TOP", 0, -5)
    titleText:SetText("Справка")

    self.helpScroll, self.helpContent, self.helpBar = createScrollArea(f, 650, 15, -40, -25, 15)

    f:RegisterForDrag("LeftButton")

    f:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)

    f:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
    end)

    self.helpFrame = f
    f:Hide()
end

function UI:SetCallbacks(callbacks)
    self.callbacks = callbacks or {}
end

function UI:Show()
    self.frame:Show()
end

function UI:Hide()
    self:HideHelp()
    self.frame:Hide()
end

function UI:IsShown()
    return self.frame:IsShown()
end

function UI:HideHelp()
    if self.helpFrame then
        self.helpFrame:Hide()
    end
end

function UI:SetTitle(text)
    self.titleText:SetText(text or "")
end

function UI:SetModuleInfo(index, total)
    self.moduleText:SetText(string.format("Модуль %d из %d", index or 0, total or 0))
end

function UI:SetPrevEnabled(enabled)
    setButtonEnabled(self.prevButton, enabled)
end

function UI:SetNextEnabled(enabled)
    setButtonEnabled(self.nextButton, enabled)
end

function UI:SetHelpData(helpModules)
    self.helpModules = (type(helpModules) == "table" and #helpModules > 0) and helpModules or nil
    setButtonEnabled(self.helpButton, self.helpModules ~= nil)
end

function UI:Layout()
    if not self.contentFrame then
        return
    end

    layoutBlocks(self.blocks, self.contentFrame, self.scrollFrame, self.scrollBar)

    if self.pendingScrollValue then
        local maxScroll = select(2, self.scrollBar:GetMinMaxValues()) or 0
        local value = math.max(0, math.min(self.pendingScrollValue, maxScroll))

        self.scrollBar:SetValue(value)
        self.pendingScrollValue = nil
    end
end

function UI:LayoutHelp()
    if not self.helpContent then
        return
    end

    layoutBlocks(self.helpBlocks, self.helpContent, self.helpScroll, self.helpBar)
end

function UI:Render(blocks, resetScrollToTop)
    if resetScrollToTop == nil then
        resetScrollToTop = true
    end

    if self.editors then
        for _, editor in pairs(self.editors) do
            if editor._editBox then
                editor._editBox:ClearFocus()
            end
        end
    end

    clearBlocks(self.blocks)

    self.blocks = {}
    self.editors = {}

    for _, data in ipairs(blocks or {}) do
        local block

        if data.type == "code" then
            block = createCodeBlock(self.contentFrame, data.content or "")
        elseif data.type == "editor" then
            block = createEditorBlock(self.contentFrame, data, self)
            self.editors[block._name] = block
        else
            block = createTextBlock(self.contentFrame, data.content or "")
        end

        table.insert(self.blocks, block)
    end

    self:Layout()

    if resetScrollToTop then
        resetScroll(self.scrollFrame, self.contentFrame, self.scrollBar)
        self.pendingScrollValue = nil
    end

    self.layoutDirty = true
end

function UI:RenderHelp(raw)
    clearBlocks(self.helpBlocks)
    self.helpBlocks = {}

    for _, data in ipairs(parseContent(raw)) do
        local block

        if data.type == "code" then
            block = createCodeBlock(self.helpContent, data.content or "")
        else
            block = createTextBlock(self.helpContent, data.content or "")
        end

        table.insert(self.helpBlocks, block)
    end

    self:LayoutHelp()
    resetScroll(self.helpScroll, self.helpContent, self.helpBar)

    self.helpFrame:SetScript("OnUpdate", function(f)
        f:SetScript("OnUpdate", nil)
        self:LayoutHelp()
    end)
end

function UI:SetModuleContent(data)
    data = data or {}

    self:HideHelp()

    -- Если мы обновляем тот же самый модуль, который уже открыт,
    -- не надо прыгать в начало. Сохраняем текущую позицию скролла.
    local sameModule = self.currentModuleIndex ~= nil
        and self.currentModuleIndex == data.index
        and self.frame
        and self.frame:IsShown()

    if sameModule and self.scrollBar then
        self.pendingScrollValue = self.scrollBar:GetValue()
    else
        self.pendingScrollValue = nil
    end

    self.currentModuleIndex = data.index

    self:SetTitle(data.title)
    self:SetModuleInfo(data.index, data.total)
    self:SetPrevEnabled(data.prevEnabled)
    self:SetNextEnabled(data.nextEnabled)
    self:SetHelpData(data.helpModules)

    if data.rawContent then
        self:Render(parseContent(data.rawContent), not sameModule)
    else
        self:Render(data.blocks, not sameModule)
    end

    self:Show()
end

function UI:ShowHelp(helpModules)
    if type(helpModules) ~= "table" or #helpModules == 0 then
        return
    end

    self:_CreateHelp()

    local key = table.concat(helpModules, ",")

    if self.helpFrame:IsShown() and self.helpKey == key then
        self.helpFrame:Hide()
        return
    end

    self.helpKey = key

    local db = ns_llua and ns_llua['lua'] or {}
    local raw = ""

    for _, moduleNumber in ipairs(helpModules) do
        local module = db[moduleNumber]

        if module and module.content then
            if raw ~= "" then
                raw = raw .. "\n\n<c>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</c>\n\n"
            end

            raw = raw .. module.content
        end
    end

    if raw == "" then
        self.helpFrame:Hide()
        return
    end

    self:RenderHelp(raw)
    self.helpFrame:Show()
end

function UI:GetEditor(name)
    if not self.editors then
        return nil
    end

    return self.editors[name]
end

function UI:GetEditorText(name)
    local editor = self:GetEditor(name)

    if not editor or not editor._editBox then
        return ""
    end

    return editor._editBox:GetText() or ""
end

function UI:SetEditorText(name, code)
    local editor = self:GetEditor(name)

    if not editor or not editor._editBox then
        return
    end

    code = code ~= nil and tostring(code) or ""

    editor._editBox:SetText(code)
    editor._preview:SetText(markupCode(code))

    self.layoutDirty = true
end

function UI:ClearEditorResult(name)
    local editor = self:GetEditor(name)

    if not editor then
        return
    end

    editor._resultMessage:SetText("")
    editor._expectedLabel:SetText("")
    editor._expectedText:SetText("")
    editor._currentLabel:SetText("")
    editor._currentText:SetText("")

    self.layoutDirty = true
end

function UI:SetEditorButtonEnabled(name, enabled)
    local editor = self:GetEditor(name)

    if not editor or not editor._button then
        return
    end

    setButtonEnabled(editor._button, enabled)
end

function UI:SetEditorResult(name, result)
    local editor = self:GetEditor(name)
    if not editor then
        return
    end

    result = result or {}

    local status = result.status or "info"
    local color = "|cFFFFFFFF"

    if status == "success" then
        color = "|cFF00FF00"
    elseif status == "error" then
        color = "|cFFFF8080"
    elseif status == "diff" then
        color = "|cFFFFB830"
    end

    local message = result.message ~= nil and tostring(result.message) or ""
    local expected = result.expected ~= nil and tostring(result.expected) or ""
    local current = result.current ~= nil and tostring(result.current) or ""

    if message ~= "" then
        editor._resultMessage:SetText(color .. escapePipes(message) .. "|r")
    else
        editor._resultMessage:SetText("")
    end

    if expected ~= "" then
        editor._expectedLabel:SetText("|cFFFFD700Ожидаемый результат:|r")
        editor._expectedText:SetText(markupPlain(expected))
    else
        editor._expectedLabel:SetText("")
        editor._expectedText:SetText("")
    end

    if current ~= "" then
        if result.footerSuccess then
            editor._currentLabel:SetText("|cFFFFD700Результат выполнения:|r")
            editor._currentText:SetText(
                "|cFFFFFFFF" .. escapePipes(current) .. "|r\n\n|cFF00FF00Задание выполнено!|r"
            )
        else
            editor._currentLabel:SetText("|cFFFFD700Текущий результат:|r")
            editor._currentText:SetText(markupPlain(current))
        end
    else
        if result.footerSuccess then
            editor._currentLabel:SetText("")
            editor._currentText:SetText("|cFF00FF00Задание выполнено!|r")
        else
            editor._currentLabel:SetText("")
            editor._currentText:SetText("")
        end
    end

    self.layoutDirty = true
end

-- ============================================================
-- END UI CLASS
-- ============================================================


-- ============================================================
-- TEST FUNCTION
-- ============================================================

function TestCourseUI(moduleNumber)
    moduleNumber = tonumber(moduleNumber) or 1

    local db = ns_llua and ns_llua['lua'] or {}
    local m = db[moduleNumber]

    if not m then
        print("TestCourseUI: модуль не найден: " .. tostring(moduleNumber))
        return
    end

    if not TestCourseUIFrame or not TestCourseUIFrame.SetModuleContent then
        TestCourseUIFrame = UI:new(UIParent)
    end

    local ui = TestCourseUIFrame

    ui:SetCallbacks({
        onPrev = function()
            print("UI signal: prev")
        end,

        onNext = function()
            print("UI signal: next")
        end,

        onClose = function()
            print("UI signal: close")
        end,

        onHelp = function(helpModules)
            ui:ShowHelp(helpModules or {1, 2})
        end,

        onExecute = function(editorName, code)
            print("UI signal: execute " .. tostring(editorName))

            ui:SetEditorResult(editorName, {
                status = "diff",
                message = "Заглушка: второй класс ещё не готов.",
                expected = m.expectedOutput or "Ожидаемый результат",
                current = code,
            })
        end,
    })

    local blocks = nil

    if m.type == "vartest" then
        blocks = {
            {
                type = "text",
                content = "<h>Задание: типы переменных</h>\n"
                    .. "Используй <k>/run</k> чтобы создать глобальные переменные нужного типа.\n"
                    .. "<w>Важно:</w> переменные должны быть глобальными (без <k>local</k>)!\n"
                    .. "<t>Пример:</t> <c>/run testNumber = 42</c>",
            },
        }

        if m.preloadVars then
            for _, v in ipairs(m.preloadVars) do
                table.insert(blocks, {
                    type = "text",
                    content = "<c>[i] " .. (v.desc or v.var) .. "</c>",
                })
            end
        end

        for _, task in ipairs(m.tasks or {}) do
            table.insert(blocks, {
                type = "text",
                content = "<t>[ ] " .. task.desc .. "</t>",
            })
        end

        if m.formatTask then
            table.insert(blocks, {
                type = "text",
                content = "<h>Задание на форматирование</h>\n" .. (m.formatTask.instruction or ""),
            })
        end

    elseif m.type == "commenttest" then
        blocks = {
            {
                type = "text",
                content = "<h>Задание: комментарии</h>\n" .. (m.instruction or ""),
            },
            {
                type = "editor",
                name = "commenttest",
                buttonText = "Проверить",
                code = m.initialCode or "",
            },
        }
    end

    ui:SetModuleContent({
        title = m.title,
        index = moduleNumber,
        total = #db,
        prevEnabled = moduleNumber > 1,
        nextEnabled = moduleNumber < #db,
        helpModules = m.helpModules or {1, 2},
        rawContent = blocks and nil or m.content,
        blocks = blocks,
    })
end

-- ============================================================
-- END TEST FUNCTION
-- ============================================================


function TestCourseUI(moduleNumber)
    moduleNumber = tonumber(moduleNumber) or 1

    local db = ns_llua and ns_llua['lua'] or {}
    local m = db[moduleNumber]

    if not m then
        print("TestCourseUI: модуль не найден: " .. tostring(moduleNumber))
        return
    end

    if not TestCourseUIFrame or not TestCourseUIFrame.SetModuleContent then
        TestCourseUIFrame = UI:new(UIParent)
    end

    local ui = TestCourseUIFrame

    ui:SetCallbacks({
        onPrev = function()
            print("UI signal: prev")
        end,

        onNext = function()
            print("UI signal: next")
        end,

        onClose = function()
            print("UI signal: close")
        end,

        onHelp = function(helpModules)
            ui:ShowHelp(helpModules or {1, 2})
        end,

        onExecute = function(editorName, code)
            print("UI signal: execute " .. tostring(editorName))

            -- Это заглушка ответа от второго класса.
            -- Потом здесь будет реальная проверка.
            ui:SetEditorResult(editorName, {
                status = "diff", -- success / error / diff / info
                message = "Заглушка: второй класс ещё не готов.",
                expected = m.expectedOutput or "Ожидаемый результат",
                current = code,
            })
        end,
    })

    local blocks = nil

    if m.type == "vartest" then
        blocks = {
            {
                type = "text",
                content = "<h>Задание: типы переменных</h>\n"
                    .. "Используй <k>/run</k> чтобы создать глобальные переменные нужного типа.\n"
                    .. "<w>Важно:</w> переменные должны быть глобальными (без <k>local</k>)!\n"
                    .. "<t>Пример:</t> <c>/run testNumber = 42</c>",
            },
        }

        if m.preloadVars then
            for _, v in ipairs(m.preloadVars) do
                table.insert(blocks, {
                    type = "text",
                    content = "<c>[i] " .. (v.desc or v.var) .. "</c>",
                })
            end
        end

        for _, task in ipairs(m.tasks or {}) do
            table.insert(blocks, {
                type = "text",
                content = "<t>[ ] " .. task.desc .. "</t>",
            })
        end

        if m.formatTask then
            table.insert(blocks, {
                type = "text",
                content = "<h>Задание на форматирование</h>\n" .. (m.formatTask.instruction or ""),
            })
        end

    elseif m.type == "commenttest" then
        blocks = {
            {
                type = "text",
                content = "<h>Задание: комментарии</h>\n" .. (m.instruction or ""),
            },
            {
                type = "editor",
                name = "commenttest",
                buttonText = "Проверить",
                code = m.initialCode or "",
            },
        }
    end

    ui:SetModuleContent({
        title = m.title,
        index = moduleNumber,
        total = #db,
        prevEnabled = moduleNumber > 1,
        nextEnabled = moduleNumber < #db,
        helpModules = {1, 2},
        rawContent = blocks and nil or m.content,
        blocks = blocks,
    })
end






































local function TrimString(s)
    return (tostring(s or ""):match("^%s*(.-)%s*$"))
end

local function NormalizeLines(s)
    s = tostring(s or "")
    s = s:gsub("\r\n", "\n")

    local lines = {}

    for line in s:gmatch("[^\n]+") do
        line = TrimString(line)
        if line ~= "" then
            table.insert(lines, line)
        end
    end

    return table.concat(lines, "\n")
end

local Logic = {}
Logic.__index = Logic

function Logic:EnsureSaved()
    nsDbc = nsDbc or {}
    nsDbc.luaTest = nsDbc.luaTest or {}
    nsDbc.luaTest.currentModule = nsDbc.luaTest.currentModule or 1
    nsDbc.luaTest.taskDetails = nsDbc.luaTest.taskDetails or {}
end

function Logic:SaveModuleProgress()
    self:EnsureSaved()

    local n = self.current
    nsDbc.luaTest.taskDetails[n] = nsDbc.luaTest.taskDetails[n] or {}

    local done = {}
    if self.done then
        for i, v in pairs(self.done) do
            done[i] = v
        end
    end

    nsDbc.luaTest.taskDetails[n].done = done
    nsDbc.luaTest.taskDetails[n].formatDone = self.formatDone == true
end

function Logic:SaveCommentTest(code, passed)
    self:EnsureSaved()

    local n = self.current
    nsDbc.luaTest.taskDetails[n] = nsDbc.luaTest.taskDetails[n] or {}

    nsDbc.luaTest.taskDetails[n].currentCode = code

    if passed ~= nil then
        nsDbc.luaTest.taskDetails[n].commentTestPassed = passed == true
        nsDbc.luaTest.taskDetails[n].completed = passed == true
    end
end

function Logic:InstallRunScript()
    if self._runScriptInstalled then
        return
    end

    self._runScriptInstalled = true

    local function resetIfModuleChanged()
        if self.runtimeModule ~= self.current then
            self.runtimeModule = self.current
            self.lastExecutedCode = nil
            self.lastPrintMessage = nil
            self.pendingConcatCount = nil
            self.insideRunScript = false
        end
    end

    self._originalPrint = _G.NSQC3_OriginalPrint or print
    _G.NSQC3_OriginalPrint = self._originalPrint

    print = function(...)
        resetIfModuleChanged()

        local parts = {}

        for i = 1, select("#", ...) do
            local value = select(i, ...)
            parts[i] = tostring(value)
        end

        self.lastPrintMessage = table.concat(parts, "\t")

        if not self.insideRunScript then
            self.lastExecutedCode = nil
            self.pendingConcatCount = nil
        end

        local result = self._originalPrint(...)

        self:CheckPrintTasks()

        return result
    end

    self._originalRunScript = _G.NSQC3_OriginalRunScript or RunScript
    _G.NSQC3_OriginalRunScript = self._originalRunScript

    if type(self._originalRunScript) == "function" then
        RunScript = function(code)
            resetIfModuleChanged()

            code = tostring(code or "")

            self.lastExecutedCode = code

            local concatCount = 0

            for _ in code:gmatch("%.%.") do
                concatCount = concatCount + 1
            end

            self.pendingConcatCount = concatCount > 0 and concatCount or nil
            self.lastPrintMessage = nil
            self.insideRunScript = true

            local result = self._originalRunScript(code)

            self.insideRunScript = false

            return result
        end
    end
end

function Logic:CheckPrintTasks()
    local m = self.db and self.db[self.current]

    if not m then
        return
    end

    if TrimString(m.type) ~= "printtest" then
        return
    end

    if not m.tasks then
        return
    end

    self.done = self.done or {}

    local msg = self.lastPrintMessage

    if not msg then
        return
    end

    local function normText(s)
        return tostring(s or ""):gsub("%s+", "")
    end

    local function normCode(s)
        s = tostring(s or "")

        -- Убираем комментарии, чтобы их можно было не учитывать
        -- при проверке ключевых слов и запрещённых слов.
        s = s:gsub("%-%-%[%[.-%]%]", "")
        s = s:gsub("%-%-[^\n]*", "")

        -- Убираем пробелы и конечные точки с запятой.
        s = s:gsub("%s+", "")
        s = s:gsub(";+$", "")

        return s
    end

    local changed = false

    for i, task in ipairs(m.tasks) do
        if not self.done[i] then
            local outputOk = true

            if task.pattern then
                outputOk = normText(msg) == normText(task.pattern)
            end

            local codeOk = true
            local code = normCode(self.lastExecutedCode or "")

            -- Старая проверка expectedExpression.
            -- Она осталась для совместимости со старыми модулями.
            if task.expectedExpression then
                codeOk = false

                if self.lastExecutedCode then
                    if type(task.expectedExpression) == "table" then
                        for _, expr in ipairs(task.expectedExpression) do
                            if code == normCode(expr) then
                                codeOk = true
                                break
                            end
                        end
                    else
                        codeOk = code == normCode(task.expectedExpression)
                    end
                end
            end

            -- Новая проверка: в коде должны быть указанные ключевые слова.
            if task.requireKeywords then
                for _, keyword in ipairs(task.requireKeywords) do
                    local cleanKeyword = tostring(keyword):gsub("%s+", "")

                    if cleanKeyword ~= "" and not code:find(cleanKeyword, 1, true) then
                        codeOk = false
                        break
                    end
                end
            end

            -- Новая проверка: в коде не должно быть запрещённых слов.
            if codeOk and task.forbidKeywords then
                for _, keyword in ipairs(task.forbidKeywords) do
                    local cleanKeyword = tostring(keyword):gsub("%s+", "")

                    if cleanKeyword ~= "" and code:find(cleanKeyword, 1, true) then
                        codeOk = false
                        break
                    end
                end
            end

            local concatOk = true

            if task.requireConcat then
                concatOk = (self.pendingConcatCount or 0) >= (tonumber(task.requiredConcatCount) or 0)
            end

            if outputOk and codeOk and concatOk then
                self.done[i] = true
                changed = true

                if PlaySoundFile then
                    PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\punto.ogg")
                end
            end

            break
        end
    end

    if not changed then
        return
    end

    local all = true

    for i in ipairs(m.tasks) do
        if not self.done[i] then
            all = false
            break
        end
    end

    self.allDone = all

    self:SaveModuleProgress()
    self:SendModuleToUI()

    if all then
        if PlaySoundFile then
            PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\fin.ogg")
        end

        if SendAddonMessage then
            SendAddonMessage("ns_Win", tostring(self.current or 0), "GUILD")
        end
    end
end

function Logic:new(ui, modules)
    local self = setmetatable({}, Logic)

    self.ui = ui
    self.db = modules or {}
    self.current = 1
    self.total = #self.db
    self.done = {}
    self.formatDone = false
    self.timer = nil
    self.nilSeen = {}
    self.allDone = false
    self.commentTestPassed = false

    self.lastExecutedCode = nil
    self.lastPrintMessage = nil
    self.pendingConcatCount = nil
    self.insideRunScript = false
    self.runtimeModule = nil

    self.ui:SetCallbacks({
        onNext = function()
            self:ManageCourse("next")
        end,

        onPrev = function()
            self:ManageCourse("prev")
        end,

        onHelp = function(helpModules)
            self.ui:ShowHelp(helpModules)
        end,

        onExecute = function(editorName, code)
            self:CheckCode(editorName, code)
        end,
    })

    self:InstallRunScript()

    return self
end

function Logic:ManageCourse(signal)
    self.total = #self.db

    if self.total == 0 then
        return
    end

    self:EnsureSaved()

    if signal == "next" then
        if self.current < self.total then
            self.current = self.current + 1
        end
    elseif signal == "prev" then
        if self.current > 1 then
            self.current = self.current - 1
        end
    else
        self.current = tonumber(signal)
            or tonumber(nsDbc.luaTest.currentModule)
            or 1

        if self.current < 1 then
            self.current = 1
        end

        if self.current > self.total then
            self.current = self.total
        end
    end

    nsDbc.luaTest.currentModule = self.current

    self.runtimeModule = self.current
    self.lastExecutedCode = nil
    self.lastPrintMessage = nil
    self.pendingConcatCount = nil
    self.insideRunScript = false

    if self.timer then
        if self.timer.Hide then
            self.timer:Hide()
        end

        if self.timer.Cancel then
            self.timer:Cancel()
        end

        self.timer = nil
    end

    self.allDone = false
    self.nilSeen = {}
    self.commentTestPassed = false

    local m = self.db[self.current]
    local saved = nsDbc.luaTest.taskDetails[self.current]

    self.done = {}
    self.formatDone = false

    if m and saved then
        if m.tasks and type(saved.done) == "table" then
            for i in ipairs(m.tasks) do
                if saved.done[i] or saved.done[tostring(i)] then
                    self.done[i] = true
                end
            end
        end

        self.formatDone = saved.formatDone == true
        self.commentTestPassed = saved.commentTestPassed == true
    end

    if m and m.preloadVars then
        for _, v in ipairs(m.preloadVars) do
            local var = TrimString(v.var)
            if var ~= "" then
                _G[var] = v.value
            end
        end
    end

    if m and m.tasks then
        for i, task in ipairs(m.tasks) do
            local var = TrimString(task.var)
            local taskType = TrimString(task.type)

            if taskType == "nil"
                and var ~= ""
                and not self.done[i]
                and _G[var] == nil then
                    _G[var] = true
            end
        end
    end

    self:SendModuleToUI()

    local mtype = TrimString(m and m.type)

    if m and (mtype == "vartest" or mtype == "customtest") and m.tasks then
        local f = CreateFrame("Frame", nil, UIParent)
        local t = 0

        f:SetScript("OnUpdate", function(_, dt)
            t = t + dt

            if t >= 0.5 then
                t = 0
                self:CheckVars()
            end
        end)

        self.timer = f
        self:CheckVars()
    end

    self.ui:Show()
end

function Logic:SendModuleToUI()
    local n = self.current or 1
    local m = self.db[n]

    if not m then
        return
    end

    self.done = self.done or {}
    self.formatDone = self.formatDone or false

    local mtype = TrimString(m.type)

    local practice = mtype == "vartest"
        or mtype == "printtest"
        or mtype == "customtest"

    local raw = m.content or ""

    if practice and raw == "" then
        raw = "<h>" .. (m.title or "Практика") .. "</h>"
    end

    if practice then
        if m.preloadVars then
            for _, v in ipairs(m.preloadVars) do
                local var = TrimString(v.var)
                local info = TrimString(v.desc or var)

                if var ~= "" and not info:find("<k>", 1, true) then
                    info = info:gsub(var, "<k>" .. var .. "</k>")
                end

                raw = raw .. "\n<c>[i] " .. info .. "</c>"
            end
        end

        if m.tasks then
            for i, task in ipairs(m.tasks) do
                local var = TrimString(task.var)
                local desc = TrimString(task.desc or var or ("Задание " .. i))

                if var ~= "" and not desc:find("<k>", 1, true) then
                    desc = desc:gsub(var, "<k>" .. var .. "</k>")
                end

                if self.done[i] then
                    raw = raw .. "\n<ok>[x] " .. desc .. "</ok>"
                else
                    raw = raw .. "\n<t>[ ] " .. desc .. "</t>"
                end
            end
        end

        if m.formatTask then
            local desc = TrimString(m.formatTask.instruction or "")

            raw = raw .. "\n<h>Задание на форматирование</h>\n"

            if self.formatDone then
                raw = raw .. "<ok>[x] " .. desc .. "</ok>"
            else
                raw = raw .. "<t>[ ] " .. desc .. "</t>"
            end
        end
    end

    local nextEnabled = true

    if mtype == "vartest" or mtype == "customtest" or mtype == "printtest" then
        if m.tasks then
            for i in ipairs(m.tasks) do
                if not self.done[i] then
                    nextEnabled = false
                    break
                end
            end
        end

        if mtype == "vartest" and m.formatTask then
            nextEnabled = nextEnabled and self.formatDone == true
        end
    end

    if mtype == "commenttest" then
        nextEnabled = self.commentTestPassed == true
    end

    local data = {
        title = m.title or "",
        index = n,
        total = self.total or #self.db,
        prevEnabled = n > 1,
        nextEnabled = nextEnabled,
        helpModules = m.helpModules,
    }

    if mtype == "commenttest" then
        self:EnsureSaved()

        local saved = nsDbc.luaTest.taskDetails[n]
        local code = (saved and saved.currentCode) or m.initialCode or ""

        if type(code) ~= "string" then
            code = tostring(code)
        end

        local blocks = {}

        -- Теперь instruction парсится как обычный контент курса.
        -- То есть внутри можно использовать <code>...</code>,
        -- и такие места будут отрисованы как блоки кода с подсветкой.
        for _, block in ipairs(parseContent(m.instruction or "")) do
            table.insert(blocks, block)
        end

        table.insert(blocks, {
            type = "editor",
            name = "commenttest",
            buttonText = "Проверить",
            code = code,
        })

        data.blocks = blocks
    else
        data.rawContent = raw
    end

    self.ui:SetModuleContent(data)

    if mtype == "commenttest" and self.commentTestPassed then
        self.ui:SetEditorButtonEnabled("commenttest", false)
    end
end

local function CheckCodeKeywords(code, requireKeywords, onlyKeywords, singleLine)
    code = tostring(code or "")

    -- Убираем комментарии.
    -- Сначала многострочные, потом однострочные.
    local noComments = code:gsub("%-%-%[%[.-%]%]", "")
    noComments = noComments:gsub("%-%-[^\n]*", "")

    -- Убираем пробелы и конечные точки с запятой.
    local cleanCode = noComments:gsub("%s+", ""):gsub(";+$", "")

    if singleLine then
        local lines = 0

        for line in noComments:gmatch("[^\r\n]+") do
            if line:match("%S") then
                lines = lines + 1
            end
        end

        if lines > 1 then
            return false, "Можно использовать только одну строку кода."
        end

        -- Если внутри остался ;, значит это уже несколько команд в одной строке.
        if cleanCode:find(";", 1, true) then
            return false, "Нельзя использовать несколько команд через точку с запятой."
        end
    end

    -- 1. Проверка, что все обязательные слова присутствуют.
    for _, keyword in ipairs(requireKeywords or {}) do
        local cleanKeyword = tostring(keyword):gsub("%s+", "")

        if cleanKeyword ~= "" and not cleanCode:find(cleanKeyword, 1, true) then
            return false, "В коде не хватает обязательного слова: " .. cleanKeyword
        end
    end

    -- 2. Если включён флаг onlyKeywords / onlyCodePatterns,
    --    проверяем, что в коде нет ничего лишнего.
    if onlyKeywords then
        local tokens = {}

        for _, keyword in ipairs(requireKeywords or {}) do
            local cleanKeyword = tostring(keyword):gsub("%s+", "")

            if cleanKeyword ~= "" then
                table.insert(tokens, cleanKeyword)
            end
        end

        -- Сначала удаляем более длинные токены.
        -- Например, string.format нужно удалять раньше, чем string.
        table.sort(tokens, function(a, b)
            return #a > #b
        end)

        local check = cleanCode

        for _, token in ipairs(tokens) do
            -- Безопасно экранируем спецсимволы Lua-паттернов.
            local escaped = token:gsub("([^%w])", "%%%1")
            check = check:gsub(escaped, "")
        end

        if check ~= "" then
            return false, "Можно использовать только указанные слова и символы."
        end
    end

    return true
end

function Logic:CheckVars()
    self.done = self.done or {}
    self.nilSeen = self.nilSeen or {}

    local m = self.db and self.db[self.current]
    if not m then
        return
    end

    local mtype = TrimString(m.type)
    if mtype ~= "vartest" and mtype ~= "customtest" then
        return
    end

    if not m.tasks then
        return
    end

    local changed = false

    for i, task in ipairs(m.tasks) do
        local var = TrimString(task.var)
        local taskType = TrimString(task.type)

        local value = nil
        if var ~= "" then
            value = _G[var]
        end

        local ok = false

        if task.check then
            local success, result = pcall(task.check, value)
            ok = success and result
        elseif taskType == "nil" then
            if var ~= "" and value ~= nil then
                self.nilSeen[var] = true
            end

            ok = var ~= ""
                and self.nilSeen[var] == true
                and type(value) == "nil"
        elseif taskType ~= "" then
            ok = type(value) == taskType
        end

        if ok and not self.done[i] then
            self.done[i] = true
            changed = true

            if PlaySoundFile then
                PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\punto.ogg")
            end
        end
    end

    local allTasks = true
    for i in ipairs(m.tasks) do
        if not self.done[i] then
            allTasks = false
            break
        end
    end

    if mtype == "vartest" and m.formatTask and allTasks and not self.formatDone then
        local msg = self.lastPrintMessage
        local code = self.lastExecutedCode

        if msg and code then
            local function normLine(s)
                return tostring(s or ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
            end

            local outputOk = normLine(msg) == normLine(m.formatTask.pattern)

            local codeOk = true

            if m.formatTask.requireKeywords
                or m.formatTask.onlyCodePatterns
                or m.formatTask.onlyKeywords
                or m.formatTask.singleLine then
                codeOk = CheckCodeKeywords(
                    code,
                    m.formatTask.requireKeywords,
                    m.formatTask.onlyCodePatterns or m.formatTask.onlyKeywords,
                    m.formatTask.singleLine
                )
            end

            if outputOk and codeOk then
                self.formatDone = true
                changed = true

                if PlaySoundFile then
                    PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\punto.ogg")
                end
            end
        end
    end

    local all = allTasks
    if mtype == "vartest" and m.formatTask then
        all = all and self.formatDone == true
    end

    local wasAllDone = self.allDone == true

    if all then
        self.allDone = true

        if self.timer then
            if self.timer.Hide then
                self.timer:Hide()
            end

            if self.timer.Cancel then
                self.timer:Cancel()
            end

            self.timer = nil
        end
    else
        self.allDone = false
    end

    if changed then
        self:SaveModuleProgress()
        self:SendModuleToUI()

        if all and not wasAllDone and mtype == "vartest" then
            if PlaySoundFile then
                PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\fin.ogg")
            end

            if SendAddonMessage then
                SendAddonMessage("ns_Win", tostring(self.current), "GUILD")
            end
        end
    end
end

function Logic:CheckCode(editorName, code)
    -- Если задание уже выполнено, ничего не делаем.
    if self.commentTestPassed then
        return
    end

    local function Trim(s)
        return (tostring(s or ""):match("^%s*(.-)%s*$"))
    end

    local function Normalize(s)
        s = tostring(s or ""):gsub("\r\n", "\n")

        local lines = {}
        for line in s:gmatch("[^\n]+") do
            line = Trim(line)
            if line ~= "" then
                table.insert(lines, line)
            end
        end

        return table.concat(lines, "\n")
    end

    local m = self.db and self.db[self.current]
    local mtype = Trim(m and m.type)

    if not m or mtype ~= "commenttest" then
        return
    end

    editorName = editorName or "commenttest"
    code = code or ""

    -- Сбрасываем preloadVars перед каждой проверкой,
    -- чтобы предыдущая неудачная попытка не портила следующую.
    if m.preloadVars then
        for _, v in ipairs(m.preloadVars) do
            local var = Trim(v.var)
            if var ~= "" then
                _G[var] = v.value
            end
        end
    end

    -- Универсальная проверка ключевых слов для commenttest.
    if m.requireKeywords or m.onlyCodePatterns or m.onlyKeywords or m.singleLine then
        local keywordOk, keywordErr = CheckCodeKeywords(
            code,
            m.requireKeywords,
            m.onlyCodePatterns or m.onlyKeywords,
            m.singleLine
        )

        if not keywordOk then
            self.commentTestPassed = false
            self:SaveCommentTest(code, false)
            self.ui:SetNextEnabled(false)
            self.ui:SetEditorResult(editorName, {
                status = "diff",
                message = keywordErr or "Неверный код.",
                expected = m.expectedCode or m.expectedOutput or "",
                current = code,
            })
            return
        end
    end

    local keywords = {
        ["and"] = true,
        ["break"] = true,
        ["do"] = true,
        ["else"] = true,
        ["elseif"] = true,
        ["end"] = true,
        ["false"] = true,
        ["for"] = true,
        ["function"] = true,
        ["if"] = true,
        ["in"] = true,
        ["local"] = true,
        ["nil"] = true,
        ["not"] = true,
        ["or"] = true,
        ["repeat"] = true,
        ["return"] = true,
        ["then"] = true,
        ["true"] = true,
        ["until"] = true,
        ["while"] = true,
        ["print"] = true,
        ["string"] = true,
        ["table"] = true,
        ["math"] = true,
        ["pairs"] = true,
        ["ipairs"] = true,
        ["type"] = true,
        ["tostring"] = true,
        ["tonumber"] = true,
        ["select"] = true,
        ["unpack"] = true,
        ["pcall"] = true,
        ["loadstring"] = true,
    }

    local function FormatValue(value, depth)
        depth = depth or 0

        local valueType = type(value)

        if valueType == "string" then
            return '"' .. value .. '"'
        elseif valueType == "number" then
            return tostring(value)
        elseif valueType == "boolean" then
            return tostring(value)
        elseif valueType == "nil" then
            return "nil"
        elseif valueType == "table" then
            if depth >= 1 then
                return "{...}"
            end

            local parts = {}
            local arraySize = #value

            if arraySize > 0 then
                local maxSize = math.min(arraySize, 5)

                for i = 1, maxSize do
                    table.insert(parts, FormatValue(value[i], depth + 1))
                end

                if arraySize > 5 then
                    table.insert(parts, "...")
                end

                return "{" .. table.concat(parts, ", ") .. "}"
            end

            local count = 0
            for k, v in pairs(value) do
                count = count + 1

                if count > 5 then
                    table.insert(parts, "...")
                    break
                end

                table.insert(parts, tostring(k) .. "=" .. FormatValue(v, depth + 1))
            end

            if count == 0 then
                return "{}"
            end

            return "{" .. table.concat(parts, ", ") .. "}"
        end

        return "<" .. valueType .. ">"
    end

    local iterationLines = {}
    local iterationCount = 0
    local traceOverflow = false
    local MAX_TRACE_LINES = 100

    local oldTraceLoop = _G.__ns_trace_loop
    local oldTraceWhile = _G.__ns_trace_while

    local function AddIterationLine(line)
        if #iterationLines < MAX_TRACE_LINES then
            table.insert(iterationLines, line)
        elseif not traceOverflow then
            traceOverflow = true
            table.insert(iterationLines, "...")
        end
    end

    _G.__ns_trace_loop = function(label, ...)
        iterationCount = iterationCount + 1

        local argCount = select("#", ...)

        if argCount == 0 then
            AddIterationLine("Итерация " .. iterationCount .. ": " .. tostring(label))
            return
        end

        local parts = {}
        for i = 1, argCount do
            parts[i] = FormatValue(select(i, ...))
        end

        AddIterationLine(
            "Итерация " .. iterationCount .. ": " .. tostring(label) .. " = " .. table.concat(parts, ", ")
        )
    end

    _G.__ns_trace_while = function(condText, vars)
        iterationCount = iterationCount + 1

        local parts = {}

        if type(vars) == "table" then
            local keys = {}

            for k in pairs(vars) do
                table.insert(keys, k)
            end

            table.sort(keys)

            for _, k in ipairs(keys) do
                if type(vars[k]) ~= "function" then
                    table.insert(parts, tostring(k) .. " = " .. FormatValue(vars[k]))
                end
            end
        end

        if #parts > 0 then
            AddIterationLine(
                "Итерация " .. iterationCount .. ": while " .. tostring(condText) .. " | " .. table.concat(parts, ", ")
            )
        else
            AddIterationLine("Итерация " .. iterationCount .. ": while " .. tostring(condText))
        end
    end

    local function InstrumentCode(source)
        local out = {}

        for line in source:gmatch("[^\r\n]+") do
            table.insert(out, line)

            local indent = line:match("^%s*") or ""
            local header = Trim(line)

            -- Убираем однострочный комментарий из конца строки,
            -- чтобы не реагировать на do внутри комментария.
            header = Trim((header:gsub("%-%-.*$", "")))

            if header ~= "" then
                -- Generic for: for i, v in ipairs(t) do
                local vars = header:match("^for%s+(.-)%s+in%s+.-%s+do%s*$")

                if vars then
                    local args = vars:gsub("%s+", "")
                    table.insert(
                        out,
                        indent .. "    __ns_trace_loop(" .. string.format("%q", args) .. ", " .. args .. ")"
                    )
                else
                    -- Numeric for: for i = 1, 10 do
                    local numVar = header:match("^for%s+(%w+)%s*=%s*.-do%s*$")

                    if numVar then
                        table.insert(
                            out,
                            indent .. "    __ns_trace_loop(" .. string.format("%q", numVar) .. ", " .. numVar .. ")"
                        )
                    else
                        -- while: while count < 5 do
                        local cond = header:match("^while%s+(.-)%s+do%s*$")

                        if cond then
                            local names = {}
                            local seen = {}

                            for word in cond:gmatch("[%a_][%w_]*") do
                                if not keywords[word] and not seen[word] then
                                    seen[word] = true
                                    table.insert(names, word)
                                end
                            end

                            local varParts = {}
                            for _, word in ipairs(names) do
                                table.insert(varParts, word .. " = " .. word)
                            end

                            table.insert(
                                out,
                                indent .. "    __ns_trace_while("
                                    .. string.format("%q", cond)
                                    .. ", {" .. table.concat(varParts, ", ") .. "})"
                            )
                        end
                    end
                end
            end
        end

        return table.concat(out, "\n")
    end

    local function ExecuteSource(source)
        local output = {}

        local oldPrint = print
        print = function(...)
            local parts = {}
            for i = 1, select("#", ...) do
                parts[i] = tostring(select(i, ...))
            end

            table.insert(output, table.concat(parts, " "))
        end

        local fn, compileErr
        if type(loadstring) == "function" then
            fn, compileErr = loadstring(source)
        else
            compileErr = "loadstring недоступен"
        end

        local ok, runErr = false, nil

        if fn then
            ok, runErr = pcall(fn)
        else
            runErr = compileErr
        end

        print = oldPrint

        return ok, runErr, table.concat(output, "\n")
    end

    -- Собираем имена переменных, которые потом покажем в итоговом отчёте.
    local candidateOrder = {}
    local candidateSeen = {}

    local function AddCandidate(name)
        name = Trim(name)

        if name == "" then
            return
        end

        if candidateSeen[name] then
            return
        end

        if keywords[name] then
            return
        end

        if not name:match("^[%a_][%w_]*$") then
            return
        end

        candidateSeen[name] = true
        table.insert(candidateOrder, name)
    end

    if type(m.reportVars) == "table" then
        for _, name in ipairs(m.reportVars) do
            AddCandidate(name)
        end
    end

    if type(m.preloadVars) == "table" then
        for _, v in ipairs(m.preloadVars) do
            AddCandidate(v.var)
        end
    end

    local searchText = tostring(m.instruction or "") .. "\n" .. tostring(m.content or "")

    for name in searchText:gmatch("<k>([%a_][%w_]*)</k>") do
        AddCandidate(name)
    end

    if type(m.requireKeywords) == "table" then
        for _, keyword in ipairs(m.requireKeywords) do
            for name in tostring(keyword):gmatch("[%a_][%w_]*") do
                AddCandidate(name)
            end
        end
    end

    local oldValues = {}
    for _, name in ipairs(candidateOrder) do
        oldValues[name] = _G[name]
    end

    local function ResetInputs()
        if m.preloadVars then
            for _, v in ipairs(m.preloadVars) do
                local var = Trim(v.var)
                if var ~= "" then
                    _G[var] = v.value
                end
            end
        end

        for _, name in ipairs(candidateOrder) do
            _G[name] = oldValues[name]
        end
    end

    local instrumentedCode = InstrumentCode(code)

    local ok, runErr, rawOutput = ExecuteSource(instrumentedCode)

    -- Если инструментированный код вдруг не собрался или упал,
    -- пробуем выполнить оригинальный код.
    if not ok and instrumentedCode ~= code then
        iterationLines = {}
        iterationCount = 0
        traceOverflow = false

        ResetInputs()

        ok, runErr, rawOutput = ExecuteSource(code)
    end

    -- ВАЖНО: не удаляем служебные функции трассировки, а ставим заглушки.
    -- Иначе если checkCode потом вызовет пользовательскую функцию,
    -- в теле которой остался __ns_trace_loop, получим ошибку
    -- "attempt to call global '__ns_trace_loop' (a nil value)".
    -- Заглушка ничего не делает, но и выполнение не ломает.
    _G.__ns_trace_loop = oldTraceLoop or function() end
    _G.__ns_trace_while = oldTraceWhile or function() end

    local problems = {}

    local outputOk = true
    if m.expectedOutput then
        outputOk = Normalize(rawOutput) == Normalize(m.expectedOutput)

        if not outputOk then
            table.insert(problems, "Неверный вывод.")
        end
    end

    local printCount = 0
    local templateOk = true
    local needPrint = tonumber(m.requiredPrintCount)

    if needPrint then
        local codeForCheck = code:gsub('"[^"]*"', '""'):gsub("'[^']*'", "''")
        local searchPos = 1

        while true do
            local startPos, endPos = codeForCheck:find("print", searchPos, true)
            if not startPos then
                break
            end

            local before = startPos > 1 and codeForCheck:sub(startPos - 1, startPos - 1) or ""
            local after = codeForCheck:sub(endPos + 1, endPos + 1) or ""

            local beforeIsWord = before ~= "" and before:match("[%w_]") ~= nil
            local afterIsWord = after ~= "" and after:match("[%w_]") ~= nil

            if not beforeIsWord and not afterIsWord then
                printCount = printCount + 1
            end

            searchPos = endPos + 1
        end

        if printCount ~= needPrint then
            templateOk = false
            table.insert(
                problems,
                ("В коде должно быть %d слов print. Найдено: %d."):format(needPrint, printCount)
            )
        end
    end

    local runtimeOk = true
    if type(m.checkCode) == "function" then
        if not ok then
            runtimeOk = false
        else
            local success, result = pcall(m.checkCode)
            runtimeOk = success and result == true
        end

        if not runtimeOk then
            table.insert(problems, "Проверка результата не пройдена.")
        end
    end

    local runOk = true

    -- Если модуль не проверяет вывод и не проверяет результат функцией,
    -- то код как минимум должен выполниться без ошибки.
    if not ok and not m.expectedOutput and type(m.checkCode) ~= "function" then
        runOk = false
        table.insert(problems, "Ошибка выполнения кода.")
    end

    local passed = outputOk and templateOk and runtimeOk and runOk

    -- Собираем подробный отчёт.
    local reportLines = {}

    if #iterationLines > 0 then
        table.insert(reportLines, "Итерации:")

        for _, line in ipairs(iterationLines) do
            table.insert(reportLines, "  " .. line)
        end
    end

    if rawOutput ~= "" then
        table.insert(reportLines, "Вывод:")

        for line in rawOutput:gmatch("[^\n]+") do
            table.insert(reportLines, "  " .. line)
        end
    end

    local finalLines = {}

    for _, name in ipairs(candidateOrder) do
        local newValue = _G[name]

        if type(newValue) ~= "function" and newValue ~= nil then
            table.insert(finalLines, name .. " = " .. FormatValue(newValue))
        end
    end

    if #finalLines > 0 then
        table.insert(reportLines, "Итог:")

        for _, line in ipairs(finalLines) do
            table.insert(reportLines, "  " .. line)
        end
    end

    if #reportLines == 0 and ok then
        table.insert(reportLines, "Код выполнен без ошибок.")
    end

    local reportText = table.concat(reportLines, "\n")

    local displayCurrent = reportText

    if not ok then
        if displayCurrent ~= "" then
            displayCurrent = displayCurrent .. "\n\n"
        end

        displayCurrent = displayCurrent .. "Ошибка: " .. tostring(runErr)
    end

    self.commentTestPassed = passed
    self:SaveCommentTest(code, passed)

    if passed then
        self.ui:SetEditorResult(editorName, {
            status = "success",
            message = "",
            expected = "",
            current = reportText,
            footerSuccess = true,
        })

        self.ui:SetNextEnabled(true)
        self.ui:SetEditorButtonEnabled(editorName, false)

        if PlaySoundFile then
            PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\fin.ogg")
        end

        if SendAddonMessage then
            SendAddonMessage("ns_Win", tostring(self.current), "GUILD")
        end
    else
        local message = table.concat(problems, " ")

        if message == "" then
            message = "Неверно."
        end

        self.ui:SetEditorResult(editorName, {
            status = "diff",
            message = message,
            expected = m.expectedCode or m.expectedOutput or "",
            current = displayCurrent,
        })

        self.ui:SetNextEnabled(false)
    end
end

logic = Logic:new(UI:new(UIParent), ns_llua and ns_llua['lua'] or {})









































































































































-- ========================================================================
-- NSReminder — напоминалка о прохождении курса Lua
-- ========================================================================

local NSReminder = {}
NSReminder.__index = NSReminder

local REMINDER_MESSAGES = {
    "Твои переменные скучают по тебе...",
    "Код сам себя не напишет!",
    "Lua ждёт тебя!",
    "Таблицы плачут без тебя",
    "Принц Артас ждёт твоего кода",
    "Прокрастинируешь?",
    "Один цикл и ты уже разработчик!",
    "string.format зовёт тебя домой",
    "Кто не учит Lua — тот не гильдмастер!",
    "Ещё один модуль и ты почти программист",
    "print('С возвращением!')",
    "Шеф уже спрашивает про твой прогресс",
    "Фарм подождёт, знания — нет",
    "Метатаблицы сами себя не объяснят",
    "local ты = 'ленивец' — исправь это!",
    "Твой персонаж уже выучил бы пару заклинаний",
    "while true do print('учи Lua') end",
    "Нажми на меня, чтобы продолжить обучение",
    "Ты не забыл про курс, правда?",
    "Где-то в ГХ плачет один учитель Lua",
    "Твои навыки кодинга ржавеют",
    "Сделай перерыв от фарма — учи Lua",
    "Таблица без данных — это просто {}",
    "Ты ближе к мастерству, чем думаешь",
    "Осталось совсем немного модулей!",
    "Хватит фармить золото, фарми знания",
    "Паладин бы уже давно прошёл этот курс",
    "nil — это то, что будет от твоих навыков",
    "return 'к курсу'",
    "Твоя гильдия гордится тобой... пока",
    "Сделай for i = 1, 10 do study() end",
    "У тебя есть незаконченные дела с Lua",
    "Твой print() молчит уже час",
    "Курс не убежит, но и сам себя не пройдёт",

    -- Новые сообщения
    "Твой прогресс в курсе = nil. Исправь это!",
    "Ошибка: attempt to index 'твой прогресс' (a nil value)",
    "if not course then print('грусть') end",
    "for i = 1, #твоей_лени do stop() end",
    "string.find(твой_день, 'Lua') вернул nil",
    "table.insert(твоя_жизнь, 'Lua')",
    "GetTime() показывает: пора на курс",
    "Твой /run заржавел без практики",
    "Не будь как local-переменная — стань глобальным!",
    "'end' не закрывает твои отговорки",
    "В чате шепчут: '... снова фармит вместо Lua'",
    "Даже мурлоки уже прошли этот курс",
    "Твоя гильдия ждёт не рейд, а твой print()",
    "Если nil — это значение, то твой прогресс — его пример",
    "В Азероте нет патча против лени",
    "Открой курс, пока сервер не ушёл на рестарт",
    "Каждый пропущенный модуль — это -1 к карме",
    "print('Привет') — уже начало пути",
    "local успех = труд + Lua",
    "if ты_тут then return end -- нет, так не выйдет",
    "while not пройден_курс do учись() end",
    "ipairs(дни) ждут твоего return",
    "pairs(отговорки) — бесконечная таблица",
    "tostring(твой_уровень) всё ещё 'новичок'",
    "tonumber('0') — столько модулей ты прошёл сегодня",
    "string.format('%s, пора учиться', UnitName('player'))",
    "UnitExists('target') есть, а цели учиться — нет",
    "UnitHealth('player') в норме, курс — нет",
    "GetMoney() не купит навык программирования",
    "Не давай курсу уйти в garbage collector (хм..а что это вообще?)",
    "Твой скилл пока на уровне testNumber = 1",
    "Даже print('Hello') лучше, чем ничего",
    "Не будь багом — стань фичей",
    "Время фармить не голд, а знания",
}

local ASSET_PAIRS = {
    {
        texture = "Interface\\AddOns\\NSQC3\\libs\\bbb.tga",
        sound   = "Interface\\AddOns\\NSQC3\\libs\\bbb.ogg",
    },
    {
        texture = "Interface\\AddOns\\NSQC3\\libs\\gob.tga",
        sound   = "Interface\\AddOns\\NSQC3\\libs\\gob.ogg",
    },
    {
        texture = "Interface\\AddOns\\NSQC3\\libs\\gom.tga",
        sound   = "Interface\\AddOns\\NSQC3\\libs\\gom.ogg",
    },
}

-- Настройки времени.
local INITIAL_DELAY         = 3          -- первая проверка через 3 секунды после входа
local MIN_REMINDER_INTERVAL = 30 * 60    -- минимум 10 минут
local MAX_REMINDER_INTERVAL = 60 * 60    -- максимум 1 час
local NOT_OPENED_RECHECK    = 60         -- если курс ещё ни разу не открывали
local API_WAIT_TIMEOUT      = 30         -- сколько ждать появления курса

-- Настройки иконки.
local MIN_ICON_SIZE   = 64
local MAX_ICON_SIZE   = 256
local POSITION_OFFSET = 400

-- ========================================================================
-- Вспомогательные функции
-- ========================================================================

local function Trim(s)
    return (tostring(s or ""):match("^%s*(.-)%s*$"))
end

local function IsCourseApiReady()
    if type(ns_llua) ~= "table" or type(ns_llua['lua']) ~= "table" then
        return false
    end

    if _G.logic and type(_G.logic.ManageCourse) == "function" then
        return true
    end

    if type(OpenLuaCourse) == "function" then
        return true
    end

    return false
end

local function HasCourseEverOpened()
    if not nsDbc or type(nsDbc.luaTest) ~= "table" then
        return false
    end

    if nsDbc.luaTest.currentModule ~= nil then
        return true
    end

    if type(nsDbc.luaTest.taskDetails) == "table" and next(nsDbc.luaTest.taskDetails) ~= nil then
        return true
    end

    if type(nsDbc.luaTest.completedModules) == "table" and next(nsDbc.luaTest.completedModules) ~= nil then
        return true
    end

    return false
end

local function IsModuleCompleted(module, saved)
    local mtype = Trim(module.type)

    -- Инфо-модули и модули без типа считаем пройденными.
    if mtype == "" or mtype == "info" then
        return true
    end

    if type(saved) ~= "table" then
        return false
    end

    -- Старый формат сохранений / общий флаг завершения.
    if saved.completed == true then
        return true
    end

    if mtype == "commenttest" then
        return saved.commentTestPassed == true
    end

    if mtype == "vartest" or mtype == "printtest" or mtype == "customtest" then
        if not module.tasks or #module.tasks == 0 then
            if mtype == "vartest" and module.formatTask then
                return saved.formatDone == true or saved.formatTaskComplete == true
            end

            return true
        end

        local allDone = true

        -- Новый формат: saved.done[i]
        if type(saved.done) == "table" then
            for i in ipairs(module.tasks) do
                if not (saved.done[i] or saved.done[tostring(i)]) then
                    allDone = false
                    break
                end
            end

        -- Старый формат: saved.taskStatus
        elseif type(saved.taskStatus) == "table" then
            for i, task in ipairs(module.tasks) do
                local taskSaved

                if mtype == "vartest" and task.var then
                    local var = Trim(task.var)

                    taskSaved = saved.taskStatus[task.var]
                        or saved.taskStatus[var]
                        or saved.taskStatus[i]
                        or saved.taskStatus[tostring(i)]
                else
                    taskSaved = saved.taskStatus[i] or saved.taskStatus[tostring(i)]
                end

                if not (taskSaved and taskSaved.completed == true) then
                    allDone = false
                    break
                end
            end
        else
            return false
        end

        if not allDone then
            return false
        end

        if mtype == "vartest" and module.formatTask then
            return saved.formatDone == true or saved.formatTaskComplete == true
        end

        return true
    end

    return true
end

local function IsCourseFinished()
    if type(ns_llua) ~= "table" or type(ns_llua['lua']) ~= "table" then
        return false
    end

    local details = nsDbc and nsDbc.luaTest and nsDbc.luaTest.taskDetails

    if type(details) ~= "table" then
        details = {}
    end

    local hasModules = false

    for moduleIndex, module in pairs(ns_llua['lua']) do
        if type(moduleIndex) == "number" and type(module) == "table" then
            hasModules = true

            if not IsModuleCompleted(module, details[moduleIndex]) then
                return false
            end
        end
    end

    return hasModules
end

local function IsCourseWindowShown()
    if _G.logic and _G.logic.ui and type(_G.logic.ui.IsShown) == "function" then
        return _G.logic.ui:IsShown()
    end

    if _G.activeLuaCourse
        and _G.activeLuaCourse.window
        and type(_G.activeLuaCourse.window.IsShown) == "function" then
        return _G.activeLuaCourse.window:IsShown()
    end

    return false
end

local function OpenCourse()
    if IsCourseWindowShown() then
        return
    end

    if _G.logic and type(_G.logic.ManageCourse) == "function" then
        _G.logic:ManageCourse()
        return
    end

    if type(OpenLuaCourse) == "function" then
        OpenLuaCourse()
    end
end

-- ========================================================================
-- NSReminder
-- ========================================================================

function NSReminder:New()
    local self = setmetatable({}, NSReminder)

    self.frame = nil
    self.icon = nil
    self.label = nil
    self.timerFrame = nil
    self.fadeFrame = nil

    self.mode = "wait"
    self.elapsed = 0
    self.nextDelay = 0

    self.lastModule = nil
    self.iconSize = MIN_ICON_SIZE
    self.suppressClick = false

    return self
end

function NSReminder:Init()
    if self.frame then
        return
    end

    self.frame = CreateFrame("Button", nil, UIParent)

    self.frame:SetFrameStrata("TOOLTIP")
    self.frame:SetFrameLevel(100)
    self.frame:SetSize(MIN_ICON_SIZE, MIN_ICON_SIZE)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:SetClampedToScreen(true)
    self.frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    self.frame:Hide()

    self.icon = self.frame:CreateTexture(nil, "ARTWORK")
    self.icon:SetAllPoints(self.frame)
    self.icon:SetTexture(ASSET_PAIRS[1].texture)

    self.label = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.label:SetPoint("BOTTOM", self.frame, "TOP", 0, 5)
    self.label:SetJustifyH("CENTER")
    self.label:SetWidth(400)
    self.label:SetTextColor(1, 0.84, 0, 1)
    self.label:SetShadowOffset(1, -1)
    self.label:SetShadowColor(0, 0, 0, 1)

    self.frame:SetScript("OnEnter", function(frame)
        GameTooltip:SetOwner(frame, "ANCHOR_TOP")
        GameTooltip:SetText("Напоминание о курсе Lua", 1, 0.84, 0)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFFFFFЛКМ:|r Открыть курс", 1, 1, 1)
        GameTooltip:AddLine("|cFFFFFFFFПКМ:|r Скрыть или перезапустить (рандом 1 из 3)", 1, 1, 1)
        GameTooltip:AddLine("|cFFFFFFFFShift+ЛКМ или СКМ:|r Перетащить", 1, 1, 1)
        GameTooltip:Show()
    end)

    self.frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.frame:SetScript("OnMouseDown", function(frame, button)
        if button == "MiddleButton" then
            frame:StartMoving()
        elseif button == "LeftButton" and IsShiftKeyDown() then
            self.suppressClick = true
            frame:StartMoving()
        end
    end)

    self.frame:SetScript("OnMouseUp", function(frame, button)
        if button == "MiddleButton" or button == "LeftButton" then
            frame:StopMovingOrSizing()
        end
    end)

    self.frame:SetScript("OnClick", function(frame, button)
        if self.suppressClick then
            self.suppressClick = false
            return
        end

        if button == "LeftButton" then
            OpenCourse()
            self:Hide()
            self:ScheduleRandom()
        elseif button == "RightButton" then
            self:OnRightClick()
        end
    end)

    self.frame:SetAlpha(0)

    self.timerFrame = CreateFrame("Frame")
    self.timerFrame:Show()

    self.timerFrame:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
end

function NSReminder:OnUpdate(elapsed)
    if self.mode ~= "wait" then
        return
    end

    self.elapsed = self.elapsed + elapsed

    if self.elapsed < self.nextDelay then
        return
    end

    self.elapsed = 0

    -- Если курс никогда не открывали — не показываем напоминалку.
    if not HasCourseEverOpened() then
        self:ScheduleNotOpenedRecheck()
        return
    end

    -- Если курс полностью пройден — не показываем, но тихо проверяем снова.
    if IsCourseFinished() then
        self:ScheduleRandom()
        return
    end

    -- Если окно курса сейчас открыто — не мешаем.
    if IsCourseWindowShown() then
        self:ScheduleRandom()
        return
    end

    self:Show()
end

function NSReminder:ScheduleRandom()
    self.mode = "wait"
    self.elapsed = 0
    self.nextDelay = math.random(MIN_REMINDER_INTERVAL, MAX_REMINDER_INTERVAL)

    if self.timerFrame then
        self.timerFrame:Show()
    end
end

function NSReminder:ScheduleNotOpenedRecheck()
    self.mode = "wait"
    self.elapsed = 0
    self.nextDelay = NOT_OPENED_RECHECK

    if self.timerFrame then
        self.timerFrame:Show()
    end
end

function NSReminder:Stop()
    self.mode = "stopped"

    if self.fadeFrame then
        self.fadeFrame:SetScript("OnUpdate", nil)
        self.fadeFrame:Hide()
    end

    if self.timerFrame then
        self.timerFrame:Hide()
    end

    if self.frame then
        self.frame:Hide()
    end
end

function NSReminder:Show()
    if not self.frame then
        return
    end

    local currentModule = nsDbc and nsDbc.luaTest and nsDbc.luaTest.currentModule

    if self.lastModule ~= currentModule then
        self.lastModule = currentModule
        self.iconSize = MIN_ICON_SIZE
    end

    local message = REMINDER_MESSAGES[math.random(#REMINDER_MESSAGES)]
    self.label:SetText(message)

    local asset = ASSET_PAIRS[math.random(#ASSET_PAIRS)]
    self.icon:SetTexture(asset.texture)

    self.frame:SetSize(self.iconSize, self.iconSize)

    local offsetX = math.random(-POSITION_OFFSET, POSITION_OFFSET)
    local offsetY = math.random(-POSITION_OFFSET, POSITION_OFFSET)

    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", offsetX, offsetY)

    self.frame:Show()
    self:StartFade(self.frame:GetAlpha(), 1, 0.3)

    if PlaySoundFile then
        PlaySoundFile(asset.sound)
    end

    if self.iconSize < MAX_ICON_SIZE then
        self.iconSize = self.iconSize * 2

        if self.iconSize > MAX_ICON_SIZE then
            self.iconSize = MAX_ICON_SIZE
        end
    end

    -- Иконка висит до клика, таймер пока не нужен.
    self.mode = "shown"

    if self.timerFrame then
        self.timerFrame:Hide()
    end
end

function NSReminder:Hide()
    if not self.frame then
        return
    end

    if not self.frame:IsShown() then
        return
    end

    self:StartFade(self.frame:GetAlpha(), 0, 0.3)
end

function NSReminder:OnRightClick()
    local roll = math.random(1, 3)

    if roll == 3 then
        -- Скрываем до следующей плановой проверки.
        self:Hide()
        self:ScheduleRandom()
    else
        -- Тут же перезапускаем напоминалку.
        self:Hide()
        self:Show()
    end
end

function NSReminder:StartFade(fromAlpha, toAlpha, duration)
    if self.fadeFrame then
        self.fadeFrame:SetScript("OnUpdate", nil)
        self.fadeFrame:Hide()
    end

    if not self.frame then
        return
    end

    self.fadeFrame = CreateFrame("Frame")
    self.fadeFrame:Show()

    local elapsed = 0

    self.fadeFrame:SetScript("OnUpdate", function(frame, dt)
        elapsed = elapsed + dt

        local progress = elapsed / duration

        if progress >= 1 then
            self.frame:SetAlpha(toAlpha)

            if toAlpha == 0 then
                self.frame:Hide()
            end

            frame:SetScript("OnUpdate", nil)
            frame:Hide()
        else
            local currentAlpha = fromAlpha + (toAlpha - fromAlpha) * progress
            self.frame:SetAlpha(currentAlpha)
        end
    end)
end

-- ========================================================================
-- Инициализация при входе в игру
-- ========================================================================

local function InitNSReminder()
    if _G.NSReminderInstance then
        return
    end

    if not UIParent then
        return
    end

    if not IsCourseApiReady() then
        return
    end

    if math.randomseed then
        math.randomseed(tonumber(time and time()) or 0)
    end

    local reminder = NSReminder:New()
    reminder:Init()

    _G.NSReminderInstance = reminder
end

local reminderLoader = CreateFrame("Frame")
reminderLoader:Show()
reminderLoader:RegisterEvent("PLAYER_LOGIN")

reminderLoader:SetScript("OnEvent", function()
    local initFrame = CreateFrame("Frame")
    initFrame:Show()

    local waitElapsed = 0

    initFrame:SetScript("OnUpdate", function(frame, elapsed)
        waitElapsed = waitElapsed + elapsed

        if waitElapsed >= INITIAL_DELAY then
            if IsCourseApiReady() then
                frame:SetScript("OnUpdate", nil)
                frame:Hide()
                InitNSReminder()
            elseif waitElapsed >= INITIAL_DELAY + API_WAIT_TIMEOUT then
                frame:SetScript("OnUpdate", nil)
                frame:Hide()
            end
        end
    end)
end)