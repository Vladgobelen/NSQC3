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

ns_llua['lua'][16.1] = {
    type = "commenttest",
    title = "Практика: предскажи результат сравнений",
    helpModules = {15, 4},
    preloadVars = {
        {var = "answer1", desc = "answer1 очищается перед проверкой"},
        {var = "answer2", desc = "answer2 очищается перед проверкой"},
        {var = "answer3", desc = "answer3 очищается перед проверкой"},
        {var = "answer4", desc = "answer4 очищается перед проверкой"},
        {var = "answer5", desc = "answer5 очищается перед проверкой"},
        {var = "answer6", desc = "answer6 очищается перед проверкой"},
    },
    reportVars = {
        "answer1",
        "answer2",
        "answer3",
        "answer4",
        "answer5",
        "answer6",
    },
    instruction = [=[
<h>Практика: предскажи результат</h>
<t>Ниже даны сравнения. Не нужно использовать print или сами операторы сравнения.</t>
<t>Твоя задача — заменить <k>nil</k> на <k>true</k> или <k>false</k> в каждой строке.</t>
<code>
5 == 5
7 ~= 7
10 > 3
10 < 3
8 >= 8
8 <= 7
</code>
<w>Пиши только answer1-answer6, знак =, true и false. Без точек с запятой и без операторов сравнения.</w>
]=],
    initialCode = [=[
answer1 = nil -- 5 == 5
answer2 = nil -- 7 ~= 7
answer3 = nil -- 10 > 3
answer4 = nil -- 10 < 3
answer5 = nil -- 8 >= 8
answer6 = nil -- 8 <= 7
]=],
    requireKeywords = {
        "answer1",
        "answer2",
        "answer3",
        "answer4",
        "answer5",
        "answer6",
        "=",
        "true",
        "false",
    },
    onlyCodePatterns = true,
    checkCode = function()
        return _G.answer1 == true
            and _G.answer2 == false
            and _G.answer3 == true
            and _G.answer4 == false
            and _G.answer5 == true
            and _G.answer6 == false
    end,
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

ns_llua['lua'][29.1] = {
    type = "info",
    title = "Изменение таблиц: table.insert, table.remove и ручное управление",
    helpModules = {4, 29},
    content = [=[
<h>Изменение таблиц</h>
<t>Таблицу можно не только создать сразу со значениями. Её можно менять: добавлять элементы, удалять их и сдвигать индексы.</t>

<h>table.insert</h>
<t>Функция <k>table.insert</k> добавляет элемент в таблицу.</t>

<t>Вариант 1: добавить в конец таблицы.</t>
<code>
local items = {"Меч"}
table.insert(items, "Щит")

print(items[1]) -- "Меч"
print(items[2]) -- "Щит"
print(#items)   -- 2
</code>

<t>Вариант 2: вставить элемент по позиции.</t>
<code>
local items = {"Меч", "Зелье"}
table.insert(items, 2, "Щит")

print(items[1]) -- "Меч"
print(items[2]) -- "Щит"
print(items[3]) -- "Зелье"
print(#items)   -- 3
</code>

<w>Важно:</w> при вставке по позиции элементы, начиная с этой позиции, сдвигаются вправо.

<h>table.remove</h>
<t>Функция <k>table.remove</k> удаляет элемент из таблицы.</t>

<t>Вариант 1: удалить последний элемент.</t>
<code>
local items = {"Меч", "Щит", "Зелье"}
table.remove(items)

print(items[1]) -- "Меч"
print(items[2]) -- "Щит"
print(items[3]) -- nil
print(#items)   -- 2
</code>

<t>Вариант 2: удалить элемент по позиции.</t>
<code>
local items = {"Меч", "Щит", "Зелье"}
table.remove(items, 2)

print(items[1]) -- "Меч"
print(items[2]) -- "Зелье"
print(#items)   -- 2
</code>

<t>Функция <k>table.remove</k> также возвращает удалённый элемент.</t>
<code>
local items = {"Меч", "Щит", "Зелье"}
local removed = table.remove(items, 2)

print(removed) -- "Щит"
print(#items)  -- 2
</code>

<h>Добавление через t[#t + 1]</h>
<t>Добавить элемент в конец таблицы можно и без <k>table.insert</k>:</t>
<code>
local items = {"Меч"}
items[#items + 1] = "Щит"

print(items[2]) -- "Щит"
print(#items)   -- 2
</code>

<t>Запись <k>t[#t + 1] = value</k> означает:</t>
<t>- взять текущую длину таблицы;</t>
<t>- прибавить 1;</t>
<t>- записать значение в следующий свободный индекс.</t>

<h>Удаление последнего элемента вручную</h>
<t>Последний элемент можно удалить, записав <k>nil</k> в последний индекс:</t>
<code>
local items = {"Меч", "Щит", "Зелье"}
items[#items] = nil

print(#items) -- 2
</code>

<w>Важно:</w> так безопасно удалять только последний элемент. Если просто записать <k>nil</k> где-нибудь в середине массива, можно получить "дырку", и оператор <k>#</k> может работать непредсказуемо.

<h>Что выбрать?</h>
<t>Для большинства задач:</t>
<t>- добавление в конец: <k>table.insert(t, value)</k> или <k>t[#t + 1] = value</k>;</t>
<t>- вставка по позиции: <k>table.insert(t, pos, value)</k>;</t>
<t>- удаление: <k>table.remove(t)</k> или <k>table.remove(t, pos)</k>.</t>

<t>Ручное управление индексами полезно для понимания, как устроена таблица, но в реальном коде чаще используют <k>table.insert</k> и <k>table.remove</k>.</t>
]=],
}

ns_llua['lua'][29.2] = {
    type = "commenttest",
    title = "Практика: вставка элементов через table.insert",
    helpModules = {29.1},
    preloadVars = {
        {var = "insertBox", desc = "insertBox очищается перед проверкой"},
    },
    reportVars = {"insertBox"},
    instruction = [=[
<h>Практика: вставка элементов через table.insert</h>
<t>Создай глобальную таблицу <k>insertBox</k>.</t>
<t>Затем добавь в неё элементы через <k>table.insert</k>.</t>

<t>Порядок действий:</t>
<t>1. Создай пустую таблицу <k>insertBox</k>.</t>
<t>2. Добавь в конец строку <s>"Меч"</s>.</t>
<t>3. Добавь в конец строку <s>"Зелье"</s>.</t>
<t>4. Вставь между ними вторым элементом строку <s>"Щит"</s>.</t>

<t>Ожидаемый результат:</t>
<code>
insertBox = {"Меч", "Щит", "Зелье"}
</code>

<w>Используй только <k>table.insert</k>. Циклы не нужны.</w>
<w>Не используй <k>local</k>, таблица нужна глобальная.</w>
]=],
    initialCode = [=[
-- Создай insertBox и добавь элементы через table.insert
]=],
    requireKeywords = {
        "table.insert",
        "insertBox",
        "2",
    },
    checkCode = function()
        return type(_G.insertBox) == "table"
            and #_G.insertBox == 3
            and _G.insertBox[1] == "Меч"
            and _G.insertBox[2] == "Щит"
            and _G.insertBox[3] == "Зелье"
    end,
}

ns_llua['lua'][29.3] = {
    type = "commenttest",
    title = "Практика: удаление элементов через table.remove",
    helpModules = {29.1},
    preloadVars = {
        {var = "removeBox", desc = "removeBox очищается перед проверкой"},
        {var = "removedItem", desc = "removedItem очищается перед проверкой"},
    },
    reportVars = {"removeBox", "removedItem"},
    instruction = [=[
<h>Практика: удаление элементов через table.remove</h>
<t>Создай глобальную таблицу <k>removeBox</k> с четырьмя строками:</t>
<s>"Меч", "Щит", "Зелье", "Факел"</s>

<t>Затем выполни удаления через <k>table.remove</k>:</t>
<t>1. Удали последний элемент.</t>
<t>2. Удали элемент с индексом 2.</t>
<t>3. Удали элемент с индексом 1 и сохрани результат в глобальную переменную <k>removedItem</k>.</t>

<t>Ожидаемый результат:</t>
<code>
removeBox = {"Зелье"}
removedItem = "Меч"
</code>

<w>Используй только <k>table.remove</k>. Циклы не нужны.</w>
<w>Не используй <k>local</k>, переменные нужны глобальные.</w>
]=],
    initialCode = [=[
-- Создай removeBox и выполни удаления через table.remove
]=],
    requireKeywords = {
        "table.remove",
        "removeBox",
        "removedItem",
        "2",
        "1",
    },
    checkCode = function()
        return type(_G.removeBox) == "table"
            and #_G.removeBox == 1
            and _G.removeBox[1] == "Зелье"
            and _G.removedItem == "Меч"
    end,
}

ns_llua['lua'][29.4] = {
    type = "commenttest",
    title = "Практика: ручное добавление элементов через t[#t + 1]",
    helpModules = {29.1},
    preloadVars = {
        {var = "manualBox", desc = "manualBox очищается перед проверкой"},
    },
    reportVars = {"manualBox"},
    instruction = [=[
<h>Практика: ручное добавление элементов</h>
<t>В этом задании нельзя использовать <k>table.insert</k> и <k>table.remove</k>.</t>
<t>Будем управлять таблицей вручную через индексы.</t>

<t>Создай глобальную таблицу <k>manualBox</k>.</t>

<t>Порядок действий:</t>
<t>1. Добавь в конец строку <s>"Меч"</s> через <k>manualBox[#manualBox + 1]</k>.</t>
<t>2. Добавь в конец строку <s>"Зелье"</s> тем же способом.</t>
<t>3. Вставь вторым элементом строку <s>"Щит"</s> вручную.</t>
<t>4. Добавь в конец строку <s>"Факел"</s> через <k>manualBox[#manualBox + 1]</k>.</t>

<h>Подсказка по ручной вставке</h>
<t>Чтобы вставить элемент в позицию 2, сначала сдвинь текущий второй элемент в третий индекс:</t>
<code>
manualBox[3] = manualBox[2]
manualBox[2] = "Щит"
</code>

<t>Ожидаемый результат:</t>
<code>
manualBox = {"Меч", "Щит", "Зелье", "Факел"}
</code>

<w>Не используй <k>local</k>, таблица нужна глобальная.</w>
<w>Циклы не нужны.</w>
]=],
    initialCode = [=[
-- Создай manualBox и заполни её вручную
]=],
    requireKeywords = {
        "manualBox",
        "#manualBox",
        "manualBox[3]",
        "manualBox[2]",
    },
    forbidKeywords = {
        "table.insert",
        "table.remove",
    },
    checkCode = function()
        return type(_G.manualBox) == "table"
            and #_G.manualBox == 4
            and _G.manualBox[1] == "Меч"
            and _G.manualBox[2] == "Щит"
            and _G.manualBox[3] == "Зелье"
            and _G.manualBox[4] == "Факел"
    end,
}

ns_llua['lua'][29.5] = {
    type = "commenttest",
    title = "Практика: ручное удаление элементов",
    helpModules = {29.1},
    preloadVars = {
        {var = "manualRemove", desc = "manualRemove очищается перед проверкой"},
    },
    reportVars = {"manualRemove"},
    instruction = [=[
<h>Практика: ручное удаление элементов</h>
<t>Создай глобальную таблицу <k>manualRemove</k> с четырьмя строками по порядку:</t>
<s>"Меч", "Щит", "Зелье", "Факел"</s>

<t>Затем вручную удали из неё два элемента:</t>
<t>1. Последний элемент.</t>
<t>2. Второй элемент. Для этого сначала сдвинь третий элемент на место второго, затем убери лишний последний элемент.</t>

<t>Ожидаемый результат:</t>
<code>
manualRemove = {"Меч", "Зелье"}
</code>

<w>Нельзя использовать <k>table.remove</k>, <k>table.insert</k>, <k>local</k> и циклы.</w>
]=],
    initialCode = [=[
-- Напиши код здесь
]=],
    requireKeywords = {
        "manualRemove",
        "#manualRemove",
        "nil",
        "manualRemove[2]",
        "manualRemove[3]",
    },
    forbidKeywords = {
        "table.remove",
        "table.insert",
    },
    checkCode = function()
        return type(_G.manualRemove) == "table"
            and #_G.manualRemove == 2
            and _G.manualRemove[1] == "Меч"
            and _G.manualRemove[2] == "Зелье"
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

ns_llua['lua'][31.1] = {
    type = "commenttest",
    title = "Практика: table.insert и цикл for",
    helpModules = {31, 29.1},
    preloadVars = {
        {var = "loopNumbers", desc = "loopNumbers очищается перед проверкой"},
    },
    reportVars = {"loopNumbers"},
    instruction = [=[
<h>Практика: table.insert и цикл for</h>
<t>Создай глобальную таблицу <k>loopNumbers</k>.</t>
<t>Заполни её числами от 1 до 5 с помощью цикла <k>for</k> и функции <k>table.insert</k>.</t>

<t>Ожидаемый результат:</t>
<code>
loopNumbers = {1, 2, 3, 4, 5}
</code>

<t>Ничего выводить не нужно.</t>
<w>Не используй <k>local</k>, таблица нужна глобальная.</w>
]=],
    initialCode = [=[
-- Создай loopNumbers и заполни её через for и table.insert
]=],
    requireKeywords = {
        "loopNumbers",
        "for",
        "do",
        "end",
        "table.insert",
        "1",
        "5",
    },
    checkCode = function()
        if type(_G.loopNumbers) ~= "table" then
            return false
        end

        if #_G.loopNumbers ~= 5 then
            return false
        end

        for i = 1, 5 do
            if _G.loopNumbers[i] ~= i then
                return false
            end
        end

        return true
    end,
}

ns_llua['lua'][31.2] = {
    type = "commenttest",
    title = "table.concat: склейка таблицы в строку",
    helpModules = {31, 29.1, 7},
    preloadVars = {
        {var = "concatWords", desc = "concatWords очищается перед проверкой"},
        {var = "concatSpace", desc = "concatSpace очищается перед проверкой"},
        {var = "concatComma", desc = "concatComma очищается перед проверкой"},
    },
    reportVars = {"concatWords", "concatSpace", "concatComma"},
    instruction = [=[
<h>table.concat</h>
<t>Функция <k>table.concat</k> склеивает элементы таблицы в одну строку.</t>
<t>Первым аргументом передаётся таблица, вторым — разделитель.</t>

<code>
local words = {"Меч", "Щит", "Зелье"}
print(table.concat(words, " "))  -- "Меч Щит Зелье"
print(table.concat(words, ", ")) -- "Меч, Щит, Зелье"
</code>

<t>Это удобнее, чем вручную собирать строку через конкатенацию в цикле.</t>

<h>Практика</h>
<t>Создай глобальную таблицу <k>concatWords</k> с тремя строками:</t>
<s>"Меч", "Щит", "Зелье"</s>

<t>Создай глобальную переменную <k>concatSpace</k>:</t>
<t>Используй <k>table.concat</k> с разделителем <s>" "</s> (пробел).</t>

<t>Создай глобальную переменную <k>concatComma</k>:</t>
<t>Используй <k>table.concat</k> с разделителем <s>", "</s> (запятая и пробел).</t>

<t>Ожидаемый результат:</t>
<code>
concatSpace = "Меч Щит Зелье"
concatComma = "Меч, Щит, Зелье"
</code>

<t>Ничего выводить не нужно.</t>
<w>Не используй <k>local</k>, переменные нужны глобальные.</w>
]=],
    initialCode = [=[
-- Создай concatWords, concatSpace и concatComma
]=],
    requireKeywords = {
        "concatWords",
        "concatSpace",
        "concatComma",
        "table.concat",
    },
    checkCode = function()
        return type(_G.concatWords) == "table"
            and #_G.concatWords == 3
            and _G.concatWords[1] == "Меч"
            and _G.concatWords[2] == "Щит"
            and _G.concatWords[3] == "Зелье"
            and _G.concatSpace == "Меч Щит Зелье"
            and _G.concatComma == "Меч, Щит, Зелье"
    end,
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
    helpModules = {31, 10, 17},
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
    helpModules = {31, 4, 17},
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

ns_llua['lua'][41.1] = {
    type = "commenttest",
    title = "Практика: фильтрация таблицы через string.find и table.insert",
    helpModules = {31, 33, 29.1},
    preloadVars = {
        {var = "filterItems", desc = "filterItems очищается перед проверкой"},
        {var = "filteredItems", desc = "filteredItems очищается перед проверкой"},
        {var = "filteredCount", desc = "filteredCount очищается перед проверкой"},
    },
    reportVars = {"filterItems", "filteredItems", "filteredCount"},
    instruction = [=[
<h>Практика: фильтрация таблицы</h>
<t>Создай глобальную таблицу <k>filterItems</k> с пятью строками по порядку:</t>
<s>"Меч", "Молот", "Кольцо", "Щит", "Плащ"</s>

<t>Создай пустую глобальную таблицу <k>filteredItems</k>.</t>

<t>Пройди по <k>filterItems</k> циклом <k>for</k> с <k>ipairs</k>.</t>
<t>Если строка содержит подстроку <s>"ол"</s>, добавь её в <k>filteredItems</k> через <k>table.insert</k>.</t>

<t>После цикла создай глобальную переменную <k>filteredCount</k> с количеством элементов в <k>filteredItems</k>.</t>

<t>Ожидаемый результат:</t>
<code>
filteredItems = {"Молот", "Кольцо"}
filteredCount = 2
</code>

<t>Ничего выводить не нужно.</t>
<w>Не используй <k>local</k>, переменные нужны глобальные.</w>
]=],
    initialCode = [=[
-- Создай filterItems, filteredItems и filteredCount
]=],
    requireKeywords = {
        "filterItems",
        "filteredItems",
        "filteredCount",
        "for",
        "ipairs",
        "do",
        "end",
        "string.find",
        "table.insert",
    },
    checkCode = function()
        return type(_G.filterItems) == "table"
            and #_G.filterItems == 5
            and _G.filterItems[1] == "Меч"
            and _G.filterItems[2] == "Молот"
            and _G.filterItems[3] == "Кольцо"
            and _G.filterItems[4] == "Щит"
            and _G.filterItems[5] == "Плащ"
            and type(_G.filteredItems) == "table"
            and #_G.filteredItems == 2
            and _G.filteredItems[1] == "Молот"
            and _G.filteredItems[2] == "Кольцо"
            and _G.filteredCount == 2
    end,
}

ns_llua['lua'][41.2] = {
    type = "commenttest",
    title = "Практика: безопасное удаление элементов при переборе",
    helpModules = {31, 32, 29.1, 40},
    preloadVars = {
        {var = "safeLoot", desc = "safeLoot очищается перед проверкой"},
        {var = "removedCount", desc = "removedCount очищается перед проверкой"},
    },
    reportVars = {"safeLoot", "removedCount"},
    instruction = [=[
<h>Практика: безопасное удаление элементов</h>
<t>Создай глобальную таблицу <k>safeLoot</k> с пятью строками по порядку:</t>
<s>"Меч", "Щит", "Зелье", "Щит", "Свиток"</s>

<t>Создай глобальную переменную <k>removedCount</k> и присвой ей 0.</t>

<t>Удали из <k>safeLoot</k> все элементы <s>"Щит"</s>.</t>
<t>Сделай это безопасным проходом с конца таблицы:</t>

<code>
for i = #safeLoot, 1, -1 do
    if safeLoot[i] == "Щит" then
        table.remove(safeLoot, i)
        removedCount = removedCount + 1
    end
end
</code>

<t>Почему с конца?</t>
<t>Когда ты удаляешь элемент, индексы следующих элементов сдвигаются.</t>
<t>Если идти с конца, сдвиги не ломают ещё не обработанные индексы.</t>

<t>Ожидаемый результат:</t>
<code>
safeLoot = {"Меч", "Зелье", "Свиток"}
removedCount = 2
</code>

<t>Ничего выводить не нужно.</t>
<w>Не используй <k>local</k>, переменные нужны глобальные.</w>
]=],
    initialCode = [=[
-- Создай safeLoot и удали все элементы "Щит" безопасным способом
]=],
    requireKeywords = {
        "safeLoot",
        "removedCount",
        "for",
        "#safeLoot",
        "-1",
        "do",
        "end",
        "if",
        "table.remove",
    },
    checkCode = function()
        return type(_G.safeLoot) == "table"
            and #_G.safeLoot == 3
            and _G.safeLoot[1] == "Меч"
            and _G.safeLoot[2] == "Зелье"
            and _G.safeLoot[3] == "Свиток"
            and _G.removedCount == 2
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
    helpModules = {31, 4, 7, 10, 17},
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

ns_llua['lua'][44.1] = {
    type = "commenttest",
    title = "Практика: базовая сортировка через table.sort",
    helpModules = {44, 29.1},
    preloadVars = {
        {var = "sortNumbers", desc = "sortNumbers очищается перед проверкой"},
    },
    reportVars = {"sortNumbers"},
    instruction = [=[
<h>Практика: базовая сортировка</h>
<t>Функция <k>table.sort</k> сортирует массив на месте.</t>
<t>То есть она меняет саму таблицу, а не возвращает новую.</t>

<t>Создай глобальную таблицу <k>sortNumbers</k> с числами:</t>
<s>7, 1, 5, 3</s>

<t>Отсортируй её по возрастанию через <k>table.sort</k>.</t>

<t>Ожидаемый результат:</t>
<code>
sortNumbers = {1, 3, 5, 7}
</code>

<t>Ничего выводить не нужно.</t>
<w>Не используй <k>local</k>, таблица нужна глобальная.</w>
]=],
    initialCode = [=[
-- Создай sortNumbers и отсортируй её через table.sort
]=],
    requireKeywords = {
        "sortNumbers",
        "table.sort",
    },
    checkCode = function()
        return type(_G.sortNumbers) == "table"
            and #_G.sortNumbers == 4
            and _G.sortNumbers[1] == 1
            and _G.sortNumbers[2] == 3
            and _G.sortNumbers[3] == 5
            and _G.sortNumbers[4] == 7
    end,
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

ns_llua['lua'][45.1] = {
    type = "commenttest",
    title = "Практика: сортировка со своим условием",
    helpModules = {45, 44.1},
    preloadVars = {
        {var = "sortDesc", desc = "sortDesc очищается перед проверкой"},
    },
    reportVars = {"sortDesc"},
    instruction = [=[
<h>Практика: сортировка со своим условием</h>
<t>По умолчанию <k>table.sort</k> сортирует элементы по возрастанию.</t>
<t>Если нужен другой порядок, в функцию сравнения передают вторым аргументом.</t>

<t>Функция сравнения должна вернуть <k>true</k>, если первый аргумент должен стоять раньше второго.</t>

<t>Пример сортировки по убыванию:</t>
<code>
table.sort(t, function(a, b)
    return a > b
end)
</code>

<h>Задание</h>
<t>Создай глобальную таблицу <k>sortDesc</k> с числами:</t>
<s>3, 8, 1, 5</s>

<t>Отсортируй её по убыванию через <k>table.sort</k> и свою функцию сравнения.</t>

<t>Ожидаемый результат:</t>
<code>
sortDesc = {8, 5, 3, 1}
</code>

<t>Ничего выводить не нужно.</t>
<w>Не используй <k>local</k>, таблица нужна глобальная.</w>
]=],
    initialCode = [=[
-- Создай sortDesc и отсортируй её по убыванию
]=],
    requireKeywords = {
        "sortDesc",
        "table.sort",
        "function",
        "return",
    },
    checkCode = function()
        return type(_G.sortDesc) == "table"
            and #_G.sortDesc == 4
            and _G.sortDesc[1] == 8
            and _G.sortDesc[2] == 5
            and _G.sortDesc[3] == 3
            and _G.sortDesc[4] == 1
    end,
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

ns_llua['lua'][46.1] = {
    type = "commenttest",
    title = "Практика: сортировка таблицы объектов через компаратор",
    helpModules = {45, 45.1, 44.1},
    preloadVars = {
        {var = "sortPlayers", desc = "sortPlayers очищается перед проверкой"},
    },
    reportVars = {"sortPlayers"},
    instruction = [=[
<h>Практика: сортировка таблицы объектов</h>
<t>Создай глобальную таблицу <k>sortPlayers</k>.</t>
<t>Внутри неё должны быть три таблицы-объекта с полями <k>name</k> и <k>level</k>:</t>

<code>
sortPlayers = {
    {name = "Тралл", level = 60},
    {name = "Артас", level = 80},
    {name = "Джайна", level = 75},
}
</code>

<t>Отсортируй <k>sortPlayers</k> так, чтобы первыми шли игроки с большим уровнем.</t>
<t>Используй <k>table.sort</k> и функцию сравнения, которая сравнивает поля <k>level</k>.</t>

<t>Ожидаемый порядок:</t>
<code>
sortPlayers[1].name = "Артас"
sortPlayers[2].name = "Джайна"
sortPlayers[3].name = "Тралл"
</code>

<t>Ничего выводить не нужно.</t>
<w>Не используй <k>local</k>, таблица нужна глобальная.</w>
]=],
    initialCode = [=[
-- Создай sortPlayers и отсортируй её по убыванию level
]=],
    requireKeywords = {
        "sortPlayers",
        "table.sort",
        "function",
        "return",
        "level",
    },
    checkCode = function()
        return type(_G.sortPlayers) == "table"
            and #_G.sortPlayers == 3
            and type(_G.sortPlayers[1]) == "table"
            and type(_G.sortPlayers[2]) == "table"
            and type(_G.sortPlayers[3]) == "table"
            and _G.sortPlayers[1].name == "Артас"
            and _G.sortPlayers[1].level == 80
            and _G.sortPlayers[2].name == "Джайна"
            and _G.sortPlayers[2].level == 75
            and _G.sortPlayers[3].name == "Тралл"
            and _G.sortPlayers[3].level == 60
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
    helpModules = {44},
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
    helpModules = {44, 45, 31, 10},
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

ns_llua['lua'][52.1] = {
    type = "commenttest",
    title = "Итоговый комбо-тест: таблицы, insert, remove, sort и concat",
    helpModules = {29.1, 31.1, 31.2, 44.1, 52},
    preloadVars = {
        {var = "finalCart", desc = "finalCart очищается перед проверкой"},
        {var = "finalCartCount", desc = "finalCartCount очищается перед проверкой"},
        {var = "finalCartText", desc = "finalCartText очищается перед проверкой"},
    },
    reportVars = {"finalCart", "finalCartCount", "finalCartText"},
    instruction = [=[
<h>Итоговый комбо-тест: таблицы</h>
<t>Создай глобальную таблицу <k>finalCart</k>.</t>

<t>Порядок действий:</t>
<t>1. Добавь через <k>table.insert</k> четыре предмета:</t>
<s>"Меч", "Зелье", "Щит", "Факел"</s>

<t>2. Удали третий элемент через <k>table.remove(finalCart, 3)</k>.</t>

<t>3. Добавь в конец предмет <s>"Компас"</s> через <k>table.insert</k>.</t>

<t>4. Отсортируй таблицу <k>finalCart</k> через <k>table.sort</k>.</t>

<t>5. Создай глобальную переменную <k>finalCartCount</k> с количеством элементов в корзине.</t>

<t>6. Создай глобальную переменную <k>finalCartText</k> через <k>table.concat</k> с разделителем <s>", "</s>.</t>

<t>Ожидаемый результат после сортировки:</t>
<code>
finalCart = {"Зелье", "Компас", "Меч", "Факел"}
finalCartCount = 4
finalCartText = "Зелье, Компас, Меч, Факел"
</code>

<t>Ничего выводить не нужно.</t>
<w>Не используй <k>local</k>, переменные нужны глобальные.</w>
]=],
    initialCode = [=[
-- Создай finalCart и выполни все операции
]=],
    requireKeywords = {
        "finalCart",
        "finalCartCount",
        "finalCartText",
        "table.insert",
        "table.remove",
        "table.sort",
        "table.concat",
        "3",
    },
    checkCode = function()
        return type(_G.finalCart) == "table"
            and #_G.finalCart == 4
            and _G.finalCart[1] == "Зелье"
            and _G.finalCart[2] == "Компас"
            and _G.finalCart[3] == "Меч"
            and _G.finalCart[4] == "Факел"
            and _G.finalCartCount == 4
            and _G.finalCartText == "Зелье, Компас, Меч, Факел"
    end,
}


















































































































































ns_llua['lua'][53] = {
type = "info",
title = "Мост Lua и WoW API",
content = [=[
<h>Мост Lua и WoW API</h>
<t>Первая часть курса дала базу: переменные, типы, условия, циклы, таблицы и функции. Теперь применяем её к WoW API.</t>
<t>WoW API — это готовые игровые функции. Они возвращают данные об игроке, цели, группе, сумках, заклинаниях и мире.</t>
<h>Простые запросы</h>
<code>
/run print(UnitName("player")) -- вывести имя персонажа
/run print(UnitLevel("player")) -- вывести уровень персонажа
/run print(UnitHealth("player")) -- вывести текущее здоровье персонажа
</code>
<h>Несколько возвращаемых значений</h>
<t>Некоторые API-функции возвращают сразу несколько значений. Для них используем множественное присваивание.</t>
<code>
/run local className, classToken = UnitClass("player"); print(className, classToken) -- получить имя класса и технический токен, затем вывести их
</code>
<t>Например, функция может вернуть название класса и технический токен:</t>
<code>
-- Пример возможного вывода:
-- Воин   WARRIOR
</code>
<h>Таблица с данными API</h>
<code>
/run playerInfo = { name = UnitName("player"), level = UnitLevel("player") }; print(playerInfo.name, playerInfo.level) -- создать глобальную таблицу с полями name и level, затем вывести их
</code>
<w>Важно:</w> если практический модуль проверяет переменную, создавай её глобальной, то есть без <k>local</k>.
<h>Зачем это нужно</h>
<t>Дальше мы будем получать данные о юнитах, считать проценты здоровья, перебирать группы и сумки, а затем создавать простые элементы интерфейса.</t>
]=],
}

ns_llua['lua'][54] = {
type = "vartest",
title = "Практика: имя и уровень игрока",
helpModules = {53},
tasks = {
{
var = "apiPlayerName",
desc = 'Создай глобальную переменную apiPlayerName и помести в неё имя игрока. Значение получи через WoW API, команду /run составь самостоятельно.',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "apiPlayerLevel",
desc = 'Создай глобальную переменную apiPlayerLevel и помести в неё уровень игрока. Значение получи через WoW API, команду /run составь самостоятельно.',
check = function(value)
return type(value) == "number" and value > 0
end,
},
},
}

ns_llua['lua'][55] = {
type = "vartest",
title = "Практика: таблица результатов класса",
helpModules = {53, 45},
tasks = {
{
var = "apiClassTable",
desc = 'Создай глобальную таблицу apiClassTable и помести в неё оба результата API-функции класса игрока: название класса и технический токен. Выполни действие через /run, одним или двумя шагами.',
check = function(value)
return type(value) == "table"
and type(value[1]) == "string"
and value[1] ~= ""
and type(value[2]) == "string"
and value[2] ~= ""
end,
},
},
}

ns_llua['lua'][56] = {
type = "commenttest",
title = "Тест: функция GetPlayerNameAndLevel",
helpModules = {53, 45},
preloadVars = {
{var = "GetPlayerNameAndLevel", desc = "GetPlayerNameAndLevel очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 53-3: функция GetPlayerNameAndLevel</h>
<t>Создай глобальную функцию <k>GetPlayerNameAndLevel()</k>.</t>
<t>Функция должна вернуть два значения:</t>
<c>1</c> — имя игрока через <k>UnitName("player")</k>.
<c>2</c> — уровень игрока через <k>UnitLevel("player")</k>.
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetPlayerNameAndLevel()
]=],
requireKeywords = {
"GetPlayerNameAndLevel",
"function",
"UnitName",
"UnitLevel",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetPlayerNameAndLevel) ~= "function" then
_G.checkError = "GetPlayerNameAndLevel не является глобальной функцией"
return false
end
local ok, name, level = pcall(_G.GetPlayerNameAndLevel)
if not ok then
_G.checkError = "Ошибка вызова GetPlayerNameAndLevel: " .. tostring(name)
return false
end
if type(name) ~= "string" or name == "" then
_G.checkError = "Первым значением функция должна вернуть имя игрока"
return false
end
if type(level) ~= "number" or level <= 0 then
_G.checkError = "Вторым значением функция должна вернуть уровень игрока"
return false
end
return true
end,
}

ns_llua['lua'][57] = {
type = "commenttest",
title = "Тест: строка playerSummary",
helpModules = {53, 7, 14},
preloadVars = {
{var = "playerSummary", desc = "playerSummary очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
"playerSummary",
},
instruction = [=[
<h>Тест: строка playerSummary</h>
<t>Создай глобальную переменную <k>playerSummary</k>.</t>
<t>Используй <k>string.format</k> и шаблон:</t>
<c>"%s/%d"</c>
<t>Первым аргументом подставь имя игрока через <k>UnitName("player")</k>.</t>
<t>Вторым аргументом подставь уровень игрока через <k>UnitLevel("player")</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную переменную playerSummary
]=],
requireKeywords = {
"playerSummary",
"string.format",
"UnitName",
"UnitLevel",
},
checkCode = function()
_G.checkError = nil

local name = UnitName("player") or ""
local level = UnitLevel("player") or 0

if type(_G.playerSummary) ~= "string" or _G.playerSummary == "" then
_G.checkError = "playerSummary должна быть непустой строкой"
return false
end

local expected = string.format("%s/%d", name, level)

if _G.playerSummary ~= expected then
_G.checkError = "playerSummary должна быть строкой вида имя/уровень, например Игрок/10"
return false
end

return true
end,
}

ns_llua['lua'][58] = {
type = "commenttest",
title = "Тест: таблица playerInfo",
helpModules = {53, 44, 45},
preloadVars = {
{var = "playerInfo", desc = "playerInfo очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
"playerInfo",
},
instruction = [=[
<h>Тест 53-5: таблица playerInfo</h>
<t>Создай глобальную таблицу <k>playerInfo</k> с полями:</t>
<c>name</c> — имя игрока через <k>UnitName("player")</k>.
<c>level</c> — уровень игрока через <k>UnitLevel("player")</k>.
<c>class</c> — название класса через первый результат <k>UnitClass("player")</k>.
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную таблицу playerInfo
]=],
requireKeywords = {
"playerInfo",
"UnitName",
"UnitLevel",
"UnitClass",
},
checkCode = function()
_G.checkError = nil
local info = _G.playerInfo
if type(info) ~= "table" then
_G.checkError = "playerInfo должна быть таблицей"
return false
end
if type(info.name) ~= "string" or info.name == "" then
_G.checkError = "Поле name должно быть строкой с именем игрока"
return false
end
if type(info.level) ~= "number" or info.level <= 0 then
_G.checkError = "Поле level должно быть числом больше нуля"
return false
end
if type(info.class) ~= "string" or info.class == "" then
_G.checkError = "Поле class должно быть строкой с названием класса"
return false
end
return true
end,
}

ns_llua['lua'][59] = {
type = "info",
title = "Особенности WoW API 3.3.5",
content = [=[
<h>Особенности WoW API 3.3.5</h>
<t>У WoW API есть несколько важных особенностей, которые нужно понимать с самого начала.</t>
<h>1. Многие функции возвращают 1 или nil</h>
<t>В старых версиях WoW многие проверки возвращают не классический <k>true</k> или <k>false</k>, а <k>1</k> или <k>nil</k>.</t>
<code>
/run print(UnitExists("player"), type(UnitExists("player"))) -- результат: 1 number. То есть вернулась 1, и её тип — number, а не boolean
</code>
<t>Поэтому лучше писать так:</t>
<code>
/run if UnitExists("target") then print("Цель есть") end -- если цель есть, выведет: Цель есть
</code>
<t>И не стоит писать так:</t>
<code>
/run if UnitExists("target") == true then print("Цель есть") end -- выведет ничего: UnitExists вернул 1, а 1 == true даёт false
</code>
<w>Причина:</w> если функция вернула <k>1</k>, то <k>1 == true</k> даст <k>false</k>.
<h>2. nil означает отсутствие данных</h>
<t>Если юнита нет, API часто возвращает <k>nil</k>.</t>
<code>
/run print(UnitName("target")) -- с целью: Шеф nil (имя + сервер, на своём сервере — nil). Без цели: nil nil
</code>
<t>Если цели нет, оба значения будут <k>nil</k>. Обрати внимание: <k>UnitName</k> возвращает два значения, второе — сервер.</t>
<h>3. Локализованные имена и технические токены</h>
<t>Некоторые функции возвращают два значения: понятное имя и технический код.</t>
<code>
/run local name, token = UnitClass("player"); print(name, token) -- пример: Рыцарь смерти DEATHKNIGHT
</code>
<t>Для вывода игроку лучше использовать <k>name</k>.</t>
<t>Для логики лучше использовать <k>token</k>, потому что он одинаковый у всех клиентов.</t>
<code>
/run local _, token = UnitClass("player"); if token == "WARRIOR" then print("Это воин") end -- у рыцаря смерти выведет ничего: токен DEATHKNIGHT, а не WARRIOR
</code>
<h>4. Отладка через /dump</h>
<t>Если не знаешь, что возвращает функция, используй <k>/dump</k>.</t>
<code>
/dump UnitClass("player")
-- результат: [1]="Рыцарь смерти", [2]="DEATHKNIGHT"
/dump UnitHealth("player")
-- результат: [1]=49045 — текущее здоровье
/dump GetMoney()
-- результат: [1]=205606460 — деньги в меди (примерно 20560 золота)
</code>
<h>5. Не все данные доступны мгновенно</h>
<t>Некоторые функции могут вернуть <k>nil</k>, если данные ещё не загрузились или кэш ещё не готов. Позже мы встретим это у предметов и гильдии.</t>
]=],
}

ns_llua['lua'][60] = {
type = "commenttest",
title = "Практика: имя цели, если цель есть",
helpModules = {59, 77},
preloadVars = {
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Практика: имя цели, если цель есть</h>
<t>Напиши код, который проверяет, существует ли текущая цель.</t>
<t>Если цель существует — выведи её имя через <k>print</k>.</t>
<t>Если цели нет — ничего выводить не нужно.</t>
<t>Перед запуском выбери кого-нибудь в таргет, например себя.</t>
]=],
initialCode = [=[
-- Если цель есть, выведи её имя
]=],
requireKeywords = {
"if",
"then",
"end",
"UnitExists",
"UnitName",
"print",
"\"target\"",
},
checkCode = function()
_G.checkError = nil

if not UnitExists("target") then
_G.checkError = "Сейчас нет цели: выбери цель (например, себя) и запусти код ещё раз"
return false
end

local name = UnitName("target")

if type(name) ~= "string" or name == "" then
_G.checkError = "Имя цели не читается: проверь, что цель выбрана, и запусти код ещё раз"
return false
end

return true
end,
}

ns_llua['lua'][61] = {
type = "commenttest",
title = "Практика: IsSameClass и таргет своего класса",
helpModules = {59, 45, 77},
preloadVars = {
{var = "IsSameClass", desc = "IsSameClass очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Практика: функция IsSameClass</h>
<t>Найди другого игрока своего класса (например, в городе или в группе) и возьми его в таргет.</t>
<t>Создай глобальную функцию <k>IsSameClass()</k>.</t>
<t>Функция должна вернуть <k>true</k>, если технический токен класса текущей цели совпадает с твоим токеном, и <k>false</k> иначе.</t>
<t>Сравнивай именно технические токены — вторые значения <k>UnitClass</k>, а не локализованные названия классов.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию IsSameClass()
]=],
requireKeywords = {
"IsSameClass",
"function",
"UnitClass",
"return",
},
checkCode = function()
_G.checkError = nil

if type(_G.IsSameClass) ~= "function" then
_G.checkError = "IsSameClass не является глобальной функцией"
return false
end

-- Хитрая проверка на тестовых данных: временно подменяем UnitClass.
local realUnitClass = UnitClass

local function RunWithFakeTokens(playerToken, targetToken)
_G.UnitClass = function(unit)
if unit == "player" then
return "Фейк", playerToken
end
if unit == "target" then
return "Фейк", targetToken
end
return realUnitClass(unit)
end
local ok, result = pcall(_G.IsSameClass)
_G.UnitClass = realUnitClass
if not ok then
return nil, result
end
return result, nil
end

local sameResult, sameErr = RunWithFakeTokens("WARRIOR", "WARRIOR")
if sameResult == nil then
_G.checkError = "Ошибка вызова IsSameClass на тестовых данных: " .. tostring(sameErr)
return false
end
if sameResult ~= true then
_G.checkError = "При совпадающих токенах классов функция должна вернуть true"
return false
end

local diffResult, diffErr = RunWithFakeTokens("WARRIOR", "MAGE")
if diffResult == nil then
_G.checkError = "Ошибка вызова IsSameClass на тестовых данных: " .. tostring(diffErr)
return false
end
if diffResult ~= false then
_G.checkError = "При разных токенах функция должна вернуть false: проверь, что сравниваешь токены через UnitClass, а не захардкодил значение"
return false
end

-- Теперь реальный мир: целью должен быть ДРУГОЙ игрок того же класса.
if not UnitExists("target") then
_G.checkError = "Нет цели: найди игрока своего класса и возьми его в таргет"
return false
end

if not UnitIsPlayer("target") then
_G.checkError = "Цель не является игроком: нужен другой игрок твоего класса"
return false
end

if UnitIsUnit("player", "target") then
_G.checkError = "Ты выбрал в таргет себя. Нужен другой игрок"
return false
end

local playerToken = select(2, UnitClass("player"))
local targetToken = select(2, UnitClass("target"))

if playerToken ~= targetToken then
_G.checkError = "Класс цели (" .. tostring(targetToken) .. ") не совпадает с твоим (" .. tostring(playerToken) .. "). Найди игрока своего класса"
return false
end

local ok, result = pcall(_G.IsSameClass)
if not ok then
_G.checkError = "Ошибка вызова IsSameClass: " .. tostring(result)
return false
end

if result ~= true then
_G.checkError = "При цели своего класса функция должна вернуть true, получено: " .. tostring(result)
return false
end

return true
end,
}

ns_llua['lua'][62] = {
type = "commenttest",
title = "Практика: HasTarget и чистый boolean",
helpModules = {59, 15},
preloadVars = {
{var = "HasTarget", desc = "HasTarget очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Практика: функция HasTarget</h>
<t>Создай глобальную функцию <k>HasTarget()</k>.</t>
<t>Функция должна вернуть <k>true</k>, если текущая цель существует, и <k>false</k>, если цели нет.</t>
<t>Помни: <k>UnitExists</k> возвращает <k>1</k> или <k>nil</k>, а не boolean. Преобразуй результат в чистый boolean, например двойным отрицанием:</t>
<code>
return not not UnitExists("target")
</code>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию HasTarget()
]=],
requireKeywords = {
"HasTarget",
"function",
"UnitExists",
"return",
},
checkCode = function()
_G.checkError = nil

if type(_G.HasTarget) ~= "function" then
_G.checkError = "HasTarget не является глобальной функцией"
return false
end

-- Проверяем логику на тестовых данных: временно подменяем UnitExists.
local realUnitExists = UnitExists

local function RunWithFakeExists(fakeValue)
_G.UnitExists = function(unit)
if unit == "target" then
return fakeValue
end
return realUnitExists(unit)
end
local ok, result = pcall(_G.HasTarget)
_G.UnitExists = realUnitExists
return ok, result
end

local okYes, yesResult = RunWithFakeExists(1)
if not okYes then
_G.checkError = "Ошибка вызова HasTarget на тестовых данных: " .. tostring(yesResult)
return false
end
if yesResult ~= true then
_G.checkError = "При существующей цели функция должна вернуть true, получено: " .. tostring(yesResult) .. ". UnitExists вернул 1 — преобразуй его в boolean"
return false
end

local okNo, noResult = RunWithFakeExists(nil)
if not okNo then
_G.checkError = "Ошибка вызова HasTarget на тестовых данных: " .. tostring(noResult)
return false
end
if noResult ~= false then
_G.checkError = "При отсутствии цели функция должна вернуть false, получено: " .. tostring(noResult) .. ". nil нужно преобразовать в false"
return false
end

-- Контрольный вызов в реальном состоянии.
local expected = UnitExists("target") and true or false
local okReal, realResult = pcall(_G.HasTarget)
if not okReal then
_G.checkError = "Ошибка вызова HasTarget: " .. tostring(realResult)
return false
end
if realResult ~= expected then
_G.checkError = "Функция вернула неверное значение для текущего состояния цели"
return false
end

return true
end,
}

ns_llua['lua'][63] = {
type = "commenttest",
title = "Тест 54-4: функция GetPlayerClassToken",
helpModules = {59, 45},
preloadVars = {
{var = "GetPlayerClassToken", desc = "GetPlayerClassToken очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 54-4: функция GetPlayerClassToken</h>
<t>Создай глобальную функцию <k>GetPlayerClassToken()</k>.</t>
<t>Функция должна вернуть только токен класса игрока.</t>
<t>Используй <k>select(2, UnitClass("player"))</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetPlayerClassToken()
]=],
requireKeywords = {
"GetPlayerClassToken",
"function",
"select",
"UnitClass",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetPlayerClassToken) ~= "function" then
_G.checkError = "GetPlayerClassToken не является глобальной функцией"
return false
end
local ok, token = pcall(_G.GetPlayerClassToken)
if not ok then
_G.checkError = "Ошибка вызова GetPlayerClassToken: " .. tostring(token)
return false
end
if type(token) ~= "string" or token == "" then
_G.checkError = "Функция должна вернуть строку с токеном класса"
return false
end
if token ~= token:upper() then
_G.checkError = "Токен класса должен быть в верхнем регистре"
return false
end
return true
end,
}

ns_llua['lua'][64] = {
type = "commenttest",
title = "Тест 54-5: функция SafeUnitName",
helpModules = {59},
preloadVars = {
{var = "SafeUnitName", desc = "SafeUnitName очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 54-5: функция SafeUnitName</h>
<t>Создай глобальную функцию <k>SafeUnitName(unit)</k>.</t>
<t>Функция должна вернуть имя юнита через <k>UnitName(unit)</k>.</t>
<t>Если имени нет, функция должна вернуть строку:</t>
<s>"Нет юнита"</s>
<t>Используй <k>or</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию SafeUnitName(unit)
]=],
requireKeywords = {
"SafeUnitName",
"function",
"UnitName",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.SafeUnitName) ~= "function" then
_G.checkError = "SafeUnitName не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.SafeUnitName, "player")
if not ok1 then
_G.checkError = "Ошибка вызова SafeUnitName('player'): " .. tostring(result1)
return false
end
if result1 ~= UnitName("player") then
_G.checkError = "Для player функция должна вернуть имя игрока"
return false
end
local ok2, result2 = pcall(_G.SafeUnitName, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова SafeUnitName('ns_invalid_unit'): " .. tostring(result2)
return false
end
if result2 ~= "Нет юнита" then
_G.checkError = "Для несуществующего юнита функция должна вернуть 'Нет юнита'"
return false
end
return true
end,
}

ns_llua['lua'][65] = {
type = "info",
title = "Безопасные шаблоны API",
helpModules = {53, 59},
content = [=[
<h>Безопасные шаблоны API</h>
<t>API часто может вернуть <k>nil</k>. Поэтому сразу учимся писать безопасный код.</t>
<h>Проверка юнита</h>
<code>
/run if UnitExists("target") then print("Цель существует") else print("Цели нет") end
</code>
<h>Значение по умолчанию через or</h>
<code>
/run local name = UnitName("target") or "Нет цели"; print(name)
</code>
<t>Если <k>UnitName</k> вернул <k>nil</k>, переменная получит строку <s>"Нет цели"</s>.</t>
<h>Число по умолчанию через or 0</h>
<code>
/run local hp = UnitHealth("player") or 0; print(hp)
</code>
<h>Защита от деления на ноль</h>
<code>
/run local hp = UnitHealth("player") or 0; local hpMax = UnitHealthMax("player") or 0; if hpMax > 0 then print(math.floor(hp / hpMax * 100)) else print(0) end
</code>
<w>Важно:</w> нельзя делить на <k>0</k> и ожидать нормальный результат. Всегда проверяй знаменатель.
<h>tonumber для странных значений</h>
<t>Если значение может быть строкой, преобразуй его в число.</t>
<code>
/run local value = tonumber("1500") or 0; print(value + 1)
</code>
<h>Шаблон безопасной функции</h>
<code>
function GetSafeHealthPercent(unit)
    local hp = UnitHealth(unit) or 0
    local hpMax = UnitHealthMax(unit) or 0
    if hpMax <= 0 then
        return 0
    end
    return math.floor(hp / hpMax * 100)
end
</code>
<t>Такой подход будет использоваться почти во всех модулях второй части.</t>
]=],
}

ns_llua['lua'][66] = {
type = "vartest",
title = "Тест 65-1: безопасное имя цели",
helpModules = {65, 53, 59},
tasks = {
{
var = "safeTargetName",
desc = 'Создай глобальную переменную safeTargetName = UnitName("target") or "нет цели"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][67] = {
type = "vartest",
title = "Тест 65-2: безопасное здоровье игрока",
helpModules = {65, 53, 59},
tasks = {
{
var = "safeHealth",
desc = 'Создай глобальную переменную safeHealth = UnitHealth("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "safeHealthMax",
desc = 'Создай глобальную переменную safeHealthMax = UnitHealthMax("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][68] = {
type = "commenttest",
title = "Тест 65-3: функция SafePercent",
helpModules = {65, 10, 17},
preloadVars = {
{var = "SafePercent", desc = "SafePercent очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 65-3: функция SafePercent</h>
<t>Создай глобальную функцию <k>SafePercent(hp, hpMax)</k>.</t>
<t>Функция должна вернуть процент здоровья.</t>
<t>Если <k>hpMax</k> меньше или равно нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть:</t>
<code>
math.floor(hp / hpMax * 100)
</code>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию SafePercent(hp, hpMax)
]=],
requireKeywords = {
"SafePercent",
"function",
"if",
"then",
"return",
"math.floor",
},
checkCode = function()
_G.checkError = nil
if type(_G.SafePercent) ~= "function" then
_G.checkError = "SafePercent не является глобальной функцией"
return false
end
local tests = {
{50, 100, 50},
{10, 0, 0},
{0, 100, 0},
{100, 100, 100},
}
for i, test in ipairs(tests) do
local ok, result = pcall(_G.SafePercent, test[1], test[2])
if not ok or result ~= test[3] then
_G.checkError = "Тест " .. i .. " функции SafePercent не пройден"
return false
end
end
return true
end,
}

ns_llua['lua'][69] = {
type = "commenttest",
title = "Тест 65-4: функция SafeNumber",
helpModules = {65, 10},
preloadVars = {
{var = "SafeNumber", desc = "SafeNumber очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 65-4: функция SafeNumber</h>
<t>Создай глобальную функцию <k>SafeNumber(value)</k>.</t>
<t>Функция должна превратить значение в число через <k>tonumber(value)</k>.</t>
<t>Если <k>tonumber</k> вернул <k>nil</k>, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть само число.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию SafeNumber(value)
]=],
requireKeywords = {
"SafeNumber",
"function",
"tonumber",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.SafeNumber) ~= "function" then
_G.checkError = "SafeNumber не является глобальной функцией"
return false
end
local tests = {
{"5", 5},
{"bad", 0},
{7, 7},
{"3.5", 3.5},
}
for i, test in ipairs(tests) do
local ok, result = pcall(_G.SafeNumber, test[1])
if not ok or result ~= test[2] then
_G.checkError = "Тест " .. i .. " функции SafeNumber не пройден"
return false
end
end
return true
end,
}

ns_llua['lua'][70] = {
type = "commenttest",
title = "Тест 65-5: функция GetSafePlayerHealthPercent",
helpModules = {65, 53, 59},
preloadVars = {
{var = "GetSafePlayerHealthPercent", desc = "GetSafePlayerHealthPercent очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 65-5: функция GetSafePlayerHealthPercent</h>
<t>Создай глобальную функцию <k>GetSafePlayerHealthPercent()</k>.</t>
<t>Функция должна вернуть процент здоровья игрока от 0 до 100.</t>
<t>Используй:</t>
<c>UnitHealth("player")</c>
<c>UnitHealthMax("player")</c>
<c>or 0</c>
<c>math.floor</c>
<t>Если максимальное здоровье меньше или равно нулю, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSafePlayerHealthPercent()
]=],
requireKeywords = {
"GetSafePlayerHealthPercent",
"function",
"UnitHealth",
"UnitHealthMax",
"math.floor",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSafePlayerHealthPercent) ~= "function" then
_G.checkError = "GetSafePlayerHealthPercent не является глобальной функцией"
return false
end
local ok, percent = pcall(_G.GetSafePlayerHealthPercent)
if not ok then
_G.checkError = "Ошибка вызова GetSafePlayerHealthPercent: " .. tostring(percent)
return false
end
if type(percent) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if percent < 0 or percent > 100 then
_G.checkError = "Процент здоровья должен быть от 0 до 100"
return false
end
local hp = UnitHealth("player") or 0
local hpMax = UnitHealthMax("player") or 0
local expected = 0
if hpMax > 0 then
expected = math.floor(hp / hpMax * 100)
end
if math.abs(percent - expected) > 5 then
_G.checkError = "Процент здоровья не совпадает с текущим здоровьем игрока"
return false
end
return true
end,
}

ns_llua['lua'][71] = {
type = "info",
title = "UnitID: player, target, party, raid",
helpModules = {53, 59, 65},
content = [=[
<h>UnitID: player, target, party, raid</h>
<t>Большинство функций WoW API принимают аргумент <k>unit</k>. Это строка-идентификатор юнита.</t>
<w>Важно:</w> UnitID пишется в кавычках, потому что это строка.
<h>Основные UnitID</h>
<c>"player"</c> — твой персонаж.
<c>"target"</c> — текущая цель.
<c>"mouseover"</c> — юнит под курсором мыши.
<c>"focus"</c> — фокус.
<c>"targettarget"</c> — цель твоей цели.
<c>"playerpet"</c> — твой питомец.
<c>"party1"</c> — первый участник группы.
<c>"party2"</c> — второй участник группы.
<c>"party3"</c> — третий участник группы.
<c>"party4"</c> — четвёртый участник группы.
<c>"raid1"</c> — первый участник рейда.
<c>"raid40"</c> — сороковой участник рейда.
<h>Примеры</h>
<code>
/run print(UnitName("player"))
/run print(UnitName("target"))
/run print(UnitName("mouseover"))
</code>
<h>Таблица юнитов</h>
<code>
/run local units = {"player", "target", "mouseover"}; for _, unit in ipairs(units) do print(unit, UnitExists(unit)) end
</code>
<t>Так можно быстро проверить, какие юниты сейчас существуют.</t>
<h>Частая ошибка</h>
<t>Неправильно:</t>
<code>
/run print(UnitName(player))
</code>
<t>Правильно:</t>
<code>
/run print(UnitName("player"))
</code>
<t>Без кавычек Lua будет искать переменную <k>player</k>, а она обычно равна <k>nil</k>.</t>
]=],
}

ns_llua['lua'][72] = {
type = "vartest",
title = "Тест 71-1: базовые UnitID",
helpModules = {71},
tasks = {
{
var = "unitPlayer",
desc = 'Создай глобальную переменную unitPlayer = "player"',
check = function(value)
return value == "player"
end,
},
{
var = "unitTarget",
desc = 'Создай глобальную переменную unitTarget = "target"',
check = function(value)
return value == "target"
end,
},
},
}

ns_llua['lua'][73] = {
type = "vartest",
title = "Тест 71-2: таблица UnitID",
helpModules = {71, 44},
tasks = {
{
var = "unitList",
desc = 'Создай глобальную таблицу unitList = {"player", "target", "mouseover"}',
check = function(value)
return type(value) == "table"
and #value == 3
and value[1] == "player"
and value[2] == "target"
and value[3] == "mouseover"
end,
},
},
}

ns_llua['lua'][74] = {
type = "commenttest",
title = "Тест 71-3: функция GetUnitList",
helpModules = {71, 45},
preloadVars = {
{var = "GetUnitList", desc = "GetUnitList очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 71-3: функция GetUnitList</h>
<t>Создай глобальную функцию <k>GetUnitList()</k>.</t>
<t>Функция должна вернуть таблицу из трёх строк:</t>
<c>"player"</c>
<c>"target"</c>
<c>"mouseover"</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetUnitList()
]=],
requireKeywords = {
"GetUnitList",
"function",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetUnitList) ~= "function" then
_G.checkError = "GetUnitList не является глобальной функцией"
return false
end
local ok, list = pcall(_G.GetUnitList)
if not ok then
_G.checkError = "Ошибка вызова GetUnitList: " .. tostring(list)
return false
end
if type(list) ~= "table" then
_G.checkError = "GetUnitList должна вернуть таблицу"
return false
end
if #list ~= 3 then
_G.checkError = "В таблице должно быть 3 элемента"
return false
end
if list[1] ~= "player" or list[2] ~= "target" or list[3] ~= "mouseover" then
_G.checkError = "Таблица должна содержать player, target, mouseover"
return false
end
return true
end,
}

ns_llua['lua'][75] = {
type = "commenttest",
title = "Тест 71-4: функция CountExistingUnits",
helpModules = {71, 45, 31},
preloadVars = {
{var = "CountExistingUnits", desc = "CountExistingUnits очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 71-4: функция CountExistingUnits</h>
<t>Создай глобальную функцию <k>CountExistingUnits(units)</k>.</t>
<t>Аргумент <k>units</k> — это таблица со строками UnitID.</t>
<t>Функция должна вернуть количество существующих юнитов.</t>
<t>Для проверки существования используй <k>UnitExists</k>.</t>
<t>Если в функцию передали не таблицу, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountExistingUnits(units)
]=],
requireKeywords = {
"CountExistingUnits",
"function",
"UnitExists",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountExistingUnits) ~= "function" then
_G.checkError = "CountExistingUnits не является глобальной функцией"
return false
end
local tests = {
{
input = {"player"},
expected = 1,
},
{
input = {"player", "player"},
expected = 2,
},
{
input = {},
expected = 0,
},
{
input = {"ns_invalid_unit"},
expected = 0,
},
{
input = "bad",
expected = 0,
},
}
for i, test in ipairs(tests) do
local ok, result = pcall(_G.CountExistingUnits, test.input)
if not ok or result ~= test.expected then
_G.checkError = "Тест " .. i .. " функции CountExistingUnits не пройден"
return false
end
end
return true
end,
}

ns_llua['lua'][76] = {
type = "commenttest",
title = "Тест 71-5: функция BuildUnitString",
helpModules = {71, 44, 45},
preloadVars = {
{var = "BuildUnitString", desc = "BuildUnitString очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 71-5: функция BuildUnitString</h>
<t>Создай глобальную функцию <k>BuildUnitString()</k>.</t>
<t>Внутри функции создай таблицу из трёх строк:</t>
<c>"player"</c>
<c>"target"</c>
<c>"mouseover"</c>
<t>Функция должна вернуть строку:</t>
<s>"player,target,mouseover"</s>
<t>Используй <k>table.concat</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию BuildUnitString()
]=],
requireKeywords = {
"BuildUnitString",
"function",
"table.concat",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.BuildUnitString) ~= "function" then
_G.checkError = "BuildUnitString не является глобальной функцией"
return false
end
local ok, result = pcall(_G.BuildUnitString)
if not ok then
_G.checkError = "Ошибка вызова BuildUnitString: " .. tostring(result)
return false
end
if result ~= "player,target,mouseover" then
_G.checkError = "Функция должна вернуть строку player,target,mouseover"
return false
end
return true
end,
}

ns_llua['lua'][77] = {
type = "info",
title = "Существование и идентификация юнита",
helpModules = {71, 65},
content = [=[
<h>Существование и идентификация юнита</h>
<t>Перед тем как использовать данные юнита, полезно проверить, существует ли он.</t>
<h>UnitExists</h>
<code>
/run print(UnitExists("player"))
/run print(UnitExists("target"))
</code>
<t>Если юнит существует, функция вернёт истинное значение. Если нет — <k>nil</k>.</t>
<h>UnitName</h>
<code>
/run print(UnitName("player"))
</code>
<t>Если юнита нет, функция вернёт <k>nil</k>.</t>
<h>UnitGUID</h>
<t>GUID — это уникальный идентификатор существа.</t>
<code>
/run print(UnitGUID("player"))
</code>
<h>UnitIsUnit</h>
<t>Проверяет, указывают ли два UnitID на одного и того же юнита.</t>
<code>
/run print(UnitIsUnit("player", "target"))
</code>
<t>Если твоя цель — ты сам, результат будет истинным.</t>
<h>UnitIsPlayer</h>
<code>
/run print(UnitIsPlayer("player"))
/run print(UnitIsPlayer("target"))
</code>
<t>Полезно отличать игроков от NPC.</t>
<h>UnitIsVisible</h>
<code>
/run print(UnitIsVisible("target"))
</code>
<t>Показывает, виден ли юнит клиенту.</t>
<h>Безопасный шаблон</h>
<code>
/run if UnitExists("target") then local name = UnitName("target"); print("Цель:", name) else print("Нет цели") end
</code>
]=],
}

ns_llua['lua'][78] = {
type = "vartest",
title = "Тест 77-1: существование и имя игрока",
helpModules = {77},
tasks = {
{
var = "playerExists",
desc = 'Создай глобальную переменную playerExists = UnitExists("player")',
check = function(value)
return value ~= nil and value ~= false
end,
},
{
var = "playerName",
desc = 'Создай глобальную переменную playerName = UnitName("player")',
check = function(value)
return type(value) == "string" and value == UnitName("player")
end,
},
},
}

ns_llua['lua'][79] = {
type = "vartest",
title = "Тест 77-2: игрок и GUID",
helpModules = {77, 15},
tasks = {
{
var = "playerIsPlayer",
desc = 'Создай глобальную переменную playerIsPlayer = not not UnitIsPlayer("player")',
check = function(value)
return value == true
end,
},
{
var = "playerGUID",
desc = 'Создай глобальную переменную playerGUID = UnitGUID("player")',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][80] = {
type = "commenttest",
title = "Тест 77-3: функция GetSafeUnitName",
helpModules = {77, 65},
preloadVars = {
{var = "GetSafeUnitName", desc = "GetSafeUnitName очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 77-3: функция GetSafeUnitName</h>
<t>Создай глобальную функцию <k>GetSafeUnitName(unit)</k>.</t>
<t>Функция должна вернуть имя юнита через <k>UnitName(unit)</k>.</t>
<t>Если имени нет, функция должна вернуть строку:</t>
<s>"Нет юнита"</s>
<t>Используй <k>or</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSafeUnitName(unit)
]=],
requireKeywords = {
"GetSafeUnitName",
"function",
"UnitName",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSafeUnitName) ~= "function" then
_G.checkError = "GetSafeUnitName не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetSafeUnitName, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetSafeUnitName('player'): " .. tostring(result1)
return false
end
if result1 ~= UnitName("player") then
_G.checkError = "Для player функция должна вернуть имя игрока"
return false
end
local ok2, result2 = pcall(_G.GetSafeUnitName, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetSafeUnitName('ns_invalid_unit'): " .. tostring(result2)
return false
end
if result2 ~= "Нет юнита" then
_G.checkError = "Для несуществующего юнита функция должна вернуть 'Нет юнита'"
return false
end
return true
end,
}

ns_llua['lua'][81] = {
type = "commenttest",
title = "Тест: функция IsSameUnit",
helpModules = {77, 45, 21},
preloadVars = {
{var = "IsSameUnit", desc = "IsSameUnit очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 77-4: функция IsSameUnit</h>
<t>Создай глобальную функцию <k>IsSameUnit(unitA, unitB)</k>.</t>
<t>Функция должна вернуть <k>true</k>, если два UnitID указывают на одного и того же юнита.</t>
<t>Иначе функция должна вернуть <k>false</k>.</t>
<t>Используй <k>UnitIsUnit</k>.</t>
<t>Чтобы результат был именно boolean, используй конструкцию:</t>
<code>
return UnitIsUnit(unitA, unitB) and true or false
</code>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию IsSameUnit(unitA, unitB)
]=],
requireKeywords = {
"IsSameUnit",
"function",
"UnitIsUnit",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.IsSameUnit) ~= "function" then
_G.checkError = "IsSameUnit не является глобальной функцией"
return false
end
local tests = {
{
args = {"player", "player"},
expected = true,
},
{
args = {"player", "ns_invalid_unit"},
expected = false,
},
{
args = {"ns_invalid_unit", "player"},
expected = false,
},
{
args = {"ns_invalid_unit", "ns_invalid_unit"},
expected = false,
},
}
for i, test in ipairs(tests) do
local ok, result = pcall(_G.IsSameUnit, test.args[1], test.args[2])
if not ok or result ~= test.expected then
_G.checkError = "Тест " .. i .. " функции IsSameUnit не пройден"
return false
end
end
return true
end,
}

ns_llua['lua'][82] = {
type = "commenttest",
title = "Тест 77-5: функция GetIdentityReport",
helpModules = {77, 45, 44},
preloadVars = {
{var = "GetIdentityReport", desc = "GetIdentityReport очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 77-5: функция GetIdentityReport</h>
<t>Создай глобальную функцию <k>GetIdentityReport(unit)</k>.</t>
<t>Функция должна вернуть таблицу с полями:</t>
<c>exists</c> — <k>true</k>, если юнит существует, иначе <k>false</k>.
<c>name</c> — имя юнита или <s>"Нет юнита"</s>, если юнита нет.
<c>isPlayer</c> — <k>true</k>, если юнит является игроком, иначе <k>false</k>.
<t>Используй:</t>
<c>UnitExists</c>
<c>UnitName</c>
<c>UnitIsPlayer</c>
<t>Для boolean-значений используй приведение через <k>and true or false</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetIdentityReport(unit)
]=],
requireKeywords = {
"GetIdentityReport",
"function",
"UnitExists",
"UnitName",
"UnitIsPlayer",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetIdentityReport) ~= "function" then
_G.checkError = "GetIdentityReport не является глобальной функцией"
return false
end
local ok1, playerReport = pcall(_G.GetIdentityReport, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetIdentityReport('player'): " .. tostring(playerReport)
return false
end
if type(playerReport) ~= "table" then
_G.checkError = "GetIdentityReport('player') должна вернуть таблицу"
return false
end
if playerReport.exists ~= true then
_G.checkError = "Для player поле exists должно быть true"
return false
end
if playerReport.name ~= UnitName("player") then
_G.checkError = "Для player поле name должно быть именем игрока"
return false
end
if playerReport.isPlayer ~= true then
_G.checkError = "Для player поле isPlayer должно быть true"
return false
end
local ok2, invalidReport = pcall(_G.GetIdentityReport, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetIdentityReport('ns_invalid_unit'): " .. tostring(invalidReport)
return false
end
if type(invalidReport) ~= "table" then
_G.checkError = "Для несуществующего юнита функция должна вернуть таблицу"
return false
end
if invalidReport.exists ~= false then
_G.checkError = "Для несуществующего юнита поле exists должно быть false"
return false
end
if invalidReport.name ~= "Нет юнита" then
_G.checkError = "Для несуществующего юнита поле name должно быть 'Нет юнита'"
return false
end
if invalidReport.isPlayer ~= false then
_G.checkError = "Для несуществующего юнита поле isPlayer должно быть false"
return false
end
return true
end,
}

ns_llua['lua'][83] = {
type = "info",
title = "Здоровье и ресурсы юнита",
helpModules = {65, 71, 77},
content = [=[
<h>Здоровье и ресурсы юнита</h>
<t>Основные функции для здоровья:</t>
<c>UnitHealth(unit)</c> — текущее здоровье.
<c>UnitHealthMax(unit)</c> — максимальное здоровье.
<code>
/run print(UnitHealth("player"), UnitHealthMax("player"))
</code>
<h>Процент здоровья</h>
<code>
/run local hp = UnitHealth("player") or 0; local hpMax = UnitHealthMax("player") or 0; if hpMax > 0 then print(math.floor(hp / hpMax * 100)) else print(0) end
</code>
<w>Важно:</w> всегда проверяй <k>hpMax > 0</k>, иначе можно получить деление на ноль.
<h>Красивый вывод через string.format</h>
<code>
/run local hp = UnitHealth("player") or 0; local hpMax = UnitHealthMax("player") or 0; if hpMax > 0 then print(string.format("HP: %d/%d (%d%%)", hp, hpMax, math.floor(hp / hpMax * 100))) end
</code>
<t>Здесь <k>%%</k> внутри <k>string.format</k> выводит обычный знак процента.</t>
<h>Ресурсы: мана, ярость, энергия</h>
<t>В WoW 3.3.5 часто используются функции:</t>
<c>UnitMana(unit)</c> — текущий ресурс.
<c>UnitManaMax(unit)</c> — максимальный ресурс.
<code>
/run print(UnitMana("player"), UnitManaMax("player"))
</code>
<t>Для разных классов ресурс может быть разным: мана, ярость, энергия, руническая сила. Функция <k>UnitMana</k> обычно возвращает текущее значение основного ресурса.</t>
<h>Тип ресурса</h>
<code>
/run print(UnitPowerType("player"))
</code>
<t>Функция может вернуть числовой код и строковый токен типа ресурса.</t>
<h>Безопасный шаблон</h>
<code>
function GetSafeUnitHealthPercent(unit)
    if not UnitExists(unit) then
        return 0
    end
    local hp = UnitHealth(unit) or 0
    local hpMax = UnitHealthMax(unit) or 0
    if hpMax <= 0 then
        return 0
    end
    return math.floor(hp / hpMax * 100)
end
</code>
]=],
}

ns_llua['lua'][84] = {
type = "vartest",
title = "Тест 83-1: здоровье игрока",
helpModules = {83, 65},
tasks = {
{
var = "myHealth",
desc = 'Создай глобальную переменную myHealth = UnitHealth("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "myHealthMax",
desc = 'Создай глобальную переменную myHealthMax = UnitHealthMax("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "healthIsSane",
desc = 'Создай глобальную переменную healthIsSane = (UnitHealth("player") or 0) <= (UnitHealthMax("player") or 0)',
check = function(value)
return value == true
end,
},
},
}

ns_llua['lua'][85] = {
type = "vartest",
title = "Тест 83-2: процент здоровья игрока",
helpModules = {83, 65, 10},
tasks = {
{
var = "myHealthPercent",
desc = 'Создай глобальную переменную myHealthPercent с процентом здоровья игрока от 0 до 100',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 100
end,
},
},
}

ns_llua['lua'][86] = {
type = "commenttest",
title = "Тест 83-3: функция GetHealthPercent",
helpModules = {83, 65, 45},
preloadVars = {
{var = "GetHealthPercent", desc = "GetHealthPercent очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 83-3: функция GetHealthPercent</h>
<t>Создай глобальную функцию <k>GetHealthPercent(unit)</k>.</t>
<t>Функция должна вернуть процент здоровья юнита от 0 до 100.</t>
<t>Если юнита нет, функция должна вернуть <n>0</n>.</t>
<t>Если максимальное здоровье меньше или равно нуля, функция должна вернуть <n>0</n>.</t>
<t>Используй:</t>
<c>UnitExists</c>
<c>UnitHealth</c>
<c>UnitHealthMax</c>
<c>math.floor</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetHealthPercent(unit)
]=],
requireKeywords = {
"GetHealthPercent",
"function",
"UnitExists",
"UnitHealth",
"UnitHealthMax",
"math.floor",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetHealthPercent) ~= "function" then
_G.checkError = "GetHealthPercent не является глобальной функцией"
return false
end
local ok, percent = pcall(_G.GetHealthPercent, "player")
if not ok then
_G.checkError = "Ошибка вызова GetHealthPercent('player'): " .. tostring(percent)
return false
end
if type(percent) ~= "number" then
_G.checkError = "GetHealthPercent должна вернуть число"
return false
end
if percent < 0 or percent > 100 then
_G.checkError = "Процент здоровья должен быть от 0 до 100"
return false
end
local hp = UnitHealth("player") or 0
local hpMax = UnitHealthMax("player") or 0
local expected = 0
if hpMax > 0 then
expected = math.floor(hp / hpMax * 100)
end
if math.abs(percent - expected) > 5 then
_G.checkError = "Процент здоровья не совпадает с текущим здоровьем игрока"
return false
end
local ok2, invalidPercent = pcall(_G.GetHealthPercent, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetHealthPercent('ns_invalid_unit'): " .. tostring(invalidPercent)
return false
end
if invalidPercent ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][87] = {
type = "commenttest",
title = "Тест 83-4: функция GetHealthText",
helpModules = {83, 65, 7},
preloadVars = {
{var = "GetHealthText", desc = "GetHealthText очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 83-4: функция GetHealthText</h>
<t>Создай глобальную функцию <k>GetHealthText(unit)</k>.</t>
<t>Если юнита нет, функция должна вернуть строку:</t>
<s>"0/0"</s>
<t>Если юнит существует, функция должна вернуть строку вида:</t>
<s>"текущее/максимальное"</s>
<t>Например:</t>
<s>"8500/10000"</s>
<t>Используй:</t>
<c>UnitExists</c>
<c>UnitHealth</c>
<c>UnitHealthMax</c>
<c>or 0</c>
<c>конкатенацию</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetHealthText(unit)
]=],
requireKeywords = {
"GetHealthText",
"function",
"UnitExists",
"UnitHealth",
"UnitHealthMax",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetHealthText) ~= "function" then
_G.checkError = "GetHealthText не является глобальной функцией"
return false
end
local ok1, playerText = pcall(_G.GetHealthText, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetHealthText('player'): " .. tostring(playerText)
return false
end
if type(playerText) ~= "string" or playerText == "" then
_G.checkError = "GetHealthText('player') должна вернуть строку"
return false
end
local hpText, maxText = playerText:match("^(%d+)/(%d+)$")
if not hpText or not maxText then
_G.checkError = "Строка для player должна иметь формат число/число"
return false
end
local hp = tonumber(hpText)
local hpMax = tonumber(maxText)
if not hp or not hpMax or hp < 0 or hpMax < 0 then
_G.checkError = "Значения здоровья должны быть числами больше или равными нулю"
return false
end
local ok2, invalidText = pcall(_G.GetHealthText, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetHealthText('ns_invalid_unit'): " .. tostring(invalidText)
return false
end
if invalidText ~= "0/0" then
_G.checkError = "Для несуществующего юнита функция должна вернуть '0/0'"
return false
end
return true
end,
}

ns_llua['lua'][88] = {
type = "commenttest",
title = "Тест 83-5: функция GetPlayerResource",
helpModules = {83, 45},
preloadVars = {
{var = "GetPlayerResource", desc = "GetPlayerResource очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 83-5: функция GetPlayerResource</h>
<t>Создай глобальную функцию <k>GetPlayerResource()</k>.</t>
<t>Функция должна вернуть два значения:</t>
<c>1</c> — текущий ресурс игрока.
<c>2</c> — максимальный ресурс игрока.
<t>Используй:</t>
<c>UnitMana("player")</c>
<c>UnitManaMax("player")</c>
<c>or 0</c>
<t>Если ресурс недоступен, оба значения должны быть числами больше или равными нулю.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetPlayerResource()
]=],
requireKeywords = {
"GetPlayerResource",
"function",
"UnitMana",
"UnitManaMax",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetPlayerResource) ~= "function" then
_G.checkError = "GetPlayerResource не является глобальной функцией"
return false
end
local ok, current, max = pcall(_G.GetPlayerResource)
if not ok then
_G.checkError = "Ошибка вызова GetPlayerResource: " .. tostring(current)
return false
end
if type(current) ~= "number" or type(max) ~= "number" then
_G.checkError = "Функция должна вернуть два числа"
return false
end
if current < 0 or max < 0 then
_G.checkError = "Значения ресурса не должны быть отрицательными"
return false
end
return true
end,
}

ns_llua['lua'][89] = {
type = "info",
title = "Состояние юнита",
helpModules = {77, 83},
content = [=[
<h>Состояние юнита</h>
<t>Эти функции помогают проверить базовое состояние юнита: жив, мёртв, в бою, онлайн, AFK и так далее.</t>
<h>Жив или мёртв</h>
<code>
/run print(UnitIsDead("player"))
/run print(UnitIsGhost("player"))
/run print(UnitIsDeadOrGhost("player"))
</code>
<t>Если функция возвращает истинное значение, условие сработает. Если <k>nil</k> или <k>false</k> — не сработает.</t>
<h>Пример</h>
<code>
/run if UnitIsDeadOrGhost("player") then print("Мёртв или призрак") else print("Жив") end
</code>
<h>Бой</h>
<code>
/run print(UnitAffectingCombat("player"))
</code>
<t>Пример условия:</t>
<code>
/run if UnitAffectingCombat("player") then print("В бою") else print("Не в бою") end
</code>
<h>Подключение и статусы</h>
<code>
/run print(UnitIsConnected("player"))
/run print(UnitIsAFK("player"))
/run print(UnitIsDND("player"))
</code>
<c>UnitIsConnected</c> — юнит онлайн.
<c>UnitIsAFK</c> — режим AFK.
<c>UnitIsDND</c> — режим «не беспокоить».
<h>Таблица статусов</h>
<code>
/run local status = { dead = UnitIsDead("player"), ghost = UnitIsGhost("player"), combat = UnitAffectingCombat("player") }; print(status.dead, status.ghost, status.combat)
</code>
<t>Такие таблицы удобно использовать для панелей и отчётов.</t>
<h>Приведение к boolean</h>
<t>Так как WoW API может возвращать <k>1</k> или <k>nil</k>, удобно превращать результат в чистый <k>true</k> / <k>false</k>:</t>
<code>
/run local isDead = not not UnitIsDead("player"); print(isDead, type(isDead))
</code>
]=],
}

ns_llua['lua'][90] = {
type = "vartest",
title = "Тест 89-1: жизнь и подключение",
helpModules = {89, 15},
tasks = {
{
var = "playerDead",
desc = 'Создай глобальную переменную playerDead = not not UnitIsDead("player")',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "playerConnected",
desc = 'Создай глобальную переменную playerConnected = not not UnitIsConnected("player")',
check = function(value)
return type(value) == "boolean" and value == true
end,
},
},
}

ns_llua['lua'][91] = {
type = "vartest",
title = "Тест 89-2: бой и статус жизни",
helpModules = {89, 17},
tasks = {
{
var = "playerCombat",
desc = 'Создай глобальную переменную playerCombat = not not UnitAffectingCombat("player")',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "playerStatusString",
desc = 'Создай глобальную переменную playerStatusString: если UnitIsDeadOrGhost("player") истинно, то "dead", иначе "alive"',
check = function(value)
return value == "dead" or value == "alive"
end,
},
},
}

ns_llua['lua'][92] = {
type = "commenttest",
title = "Тест 89-3: функция GetLifeState",
helpModules = {89, 45, 19},
preloadVars = {
{var = "GetLifeState", desc = "GetLifeState очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 89-3: функция GetLifeState</h>
<t>Создай глобальную функцию <k>GetLifeState(unit)</k>.</t>
<t>Функция должна вернуть строку:</t>
<c>"unknown"</c> — если юнита не существует.
<c>"dead"</c> — если юнит мёртв.
<c>"ghost"</c> — если юнит призрак.
<c>"alive"</c> — в остальных случаях.
<t>Используй:</t>
<c>UnitExists</c>
<c>UnitIsDead</c>
<c>UnitIsGhost</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetLifeState(unit)
]=],
requireKeywords = {
"GetLifeState",
"function",
"UnitExists",
"UnitIsDead",
"UnitIsGhost",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetLifeState) ~= "function" then
_G.checkError = "GetLifeState не является глобальной функцией"
return false
end
local validStates = {
dead = true,
ghost = true,
alive = true,
}
local ok1, playerState = pcall(_G.GetLifeState, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetLifeState('player'): " .. tostring(playerState)
return false
end
if type(playerState) ~= "string" or not validStates[playerState] then
_G.checkError = "Для player функция должна вернуть dead, ghost или alive"
return false
end
local ok2, invalidState = pcall(_G.GetLifeState, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetLifeState('ns_invalid_unit'): " .. tostring(invalidState)
return false
end
if invalidState ~= "unknown" then
_G.checkError = "Для несуществующего юнита функция должна вернуть unknown"
return false
end
return true
end,
}

ns_llua['lua'][93] = {
type = "commenttest",
title = "Тест 89-4: функция IsInCombat",
helpModules = {89, 45, 21},
preloadVars = {
{var = "IsInCombat", desc = "IsInCombat очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 89-4: функция IsInCombat</h>
<t>Создай глобальную функцию <k>IsInCombat(unit)</k>.</t>
<t>Функция должна вернуть <k>true</k>, если юнит находится в бою.</t>
<t>Иначе функция должна вернуть <k>false</k>.</t>
<t>Используй:</t>
<c>UnitAffectingCombat</c>
<t>Чтобы результат был именно boolean, используй конструкцию:</t>
<code>
return UnitAffectingCombat(unit) and true or false
</code>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию IsInCombat(unit)
]=],
requireKeywords = {
"IsInCombat",
"function",
"UnitAffectingCombat",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.IsInCombat) ~= "function" then
_G.checkError = "IsInCombat не является глобальной функцией"
return false
end
local ok1, playerCombat = pcall(_G.IsInCombat, "player")
if not ok1 then
_G.checkError = "Ошибка вызова IsInCombat('player'): " .. tostring(playerCombat)
return false
end
if type(playerCombat) ~= "boolean" then
_G.checkError = "Для player функция должна вернуть boolean"
return false
end
local ok2, invalidCombat = pcall(_G.IsInCombat, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова IsInCombat('ns_invalid_unit'): " .. tostring(invalidCombat)
return false
end
if invalidCombat ~= false then
_G.checkError = "Для несуществующего юнита функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][94] = {
type = "commenttest",
title = "Тест 89-5: функция GetStatusTable",
helpModules = {89, 45, 44},
preloadVars = {
{var = "GetStatusTable", desc = "GetStatusTable очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 89-5: функция GetStatusTable</h>
<t>Создай глобальную функцию <k>GetStatusTable(unit)</k>.</t>
<t>Функция должна вернуть таблицу с полями:</t>
<c>exists</c> — <k>true</k>, если юнит существует, иначе <k>false</k>.
<c>dead</c> — <k>true</k>, если юнит мёртв, иначе <k>false</k>.
<c>combat</c> — <k>true</k>, если юнит в бою, иначе <k>false</k>.
<c>connected</c> — <k>true</k>, если юнит онлайн, иначе <k>false</k>.
<t>Используй:</t>
<c>UnitExists</c>
<c>UnitIsDead</c>
<c>UnitAffectingCombat</c>
<c>UnitIsConnected</c>
<t>Для boolean-значений используй приведение через <k>and true or false</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetStatusTable(unit)
]=],
requireKeywords = {
"GetStatusTable",
"function",
"UnitExists",
"UnitIsDead",
"UnitAffectingCombat",
"UnitIsConnected",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetStatusTable) ~= "function" then
_G.checkError = "GetStatusTable не является глобальной функцией"
return false
end
local ok1, playerReport = pcall(_G.GetStatusTable, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetStatusTable('player'): " .. tostring(playerReport)
return false
end
if type(playerReport) ~= "table" then
_G.checkError = "GetStatusTable('player') должна вернуть таблицу"
return false
end
if playerReport.exists ~= true then
_G.checkError = "Для player поле exists должно быть true"
return false
end
if type(playerReport.dead) ~= "boolean" then
_G.checkError = "Поле dead должно быть boolean"
return false
end
if type(playerReport.combat) ~= "boolean" then
_G.checkError = "Поле combat должно быть boolean"
return false
end
if type(playerReport.connected) ~= "boolean" then
_G.checkError = "Поле connected должно быть boolean"
return false
end
local ok2, invalidReport = pcall(_G.GetStatusTable, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetStatusTable('ns_invalid_unit'): " .. tostring(invalidReport)
return false
end
if type(invalidReport) ~= "table" then
_G.checkError = "Для несуществующего юнита функция должна вернуть таблицу"
return false
end
if invalidReport.exists ~= false then
_G.checkError = "Для несуществующего юнита поле exists должно быть false"
return false
end
if invalidReport.dead ~= false then
_G.checkError = "Для несуществующего юнита поле dead должно быть false"
return false
end
if invalidReport.combat ~= false then
_G.checkError = "Для несуществующего юнита поле combat должно быть false"
return false
end
if invalidReport.connected ~= false then
_G.checkError = "Для несуществующего юнита поле connected должно быть false"
return false
end
return true
end,
}

ns_llua['lua'][95] = {
type = "info",
title = "Отношения к юниту",
helpModules = {77, 89},
content = [=[
<h>Отношения к юниту</h>
<t>Эти функции помогают понять, можно ли атаковать юнита, дружелюбен ли он, игрок ли это, PvP ли он.</t>
<h>UnitCanAttack</h>
<t>Проверяет, можешь ли ты атаковать юнита.</t>
<code>
/run print(UnitCanAttack("player", "target"))
</code>
<h>UnitIsEnemy</h>
<code>
/run print(UnitIsEnemy("player", "target"))
</code>
<h>UnitIsFriend</h>
<code>
/run print(UnitIsFriend("player", "target"))
</code>
<h>UnitCanCooperate</h>
<t>Проверяет, можно ли взаимодействовать с юнитом, например лечить его.</t>
<code>
/run print(UnitCanCooperate("player", "target"))
</code>
<h>PvP и фракция</h>
<code>
/run print(UnitIsPVP("player"))
/run print(UnitFactionGroup("player"))
</code>
<h>Безопасный пример</h>
<code>
/run if UnitExists("target") and UnitCanAttack("player", "target") then print("Цель можно атаковать") else print("Атаковать нельзя или цели нет") end
</code>
<w>Важно:</w> если цели нет, функции проверки цели могут вернуть <k>nil</k>. Поэтому сначала проверяй <k>UnitExists</k>.
<h>Комбинированное условие</h>
<code>
/run if UnitExists("target") and UnitIsFriend("player", "target") then print("Дружественная цель") end
</code>
<h>Приведение к boolean</h>
<code>
/run local canAttack = not not UnitCanAttack("player", "target"); print(canAttack, type(canAttack))
</code>
]=],
}

ns_llua['lua'][96] = {
type = "vartest",
title = "Тест 95-1: фракция игрока",
helpModules = {95},
tasks = {
{
var = "playerFaction",
desc = 'Создай глобальную переменную playerFaction = UnitFactionGroup("player")',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][97] = {
type = "vartest",
title = "Тест 95-2: проверка цели",
helpModules = {95, 15},
tasks = {
{
var = "canAttackTarget",
desc = 'Создай глобальную переменную canAttackTarget = not not UnitCanAttack("player", "target")',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "isTargetFriend",
desc = 'Создай глобальную переменную isTargetFriend = not not UnitIsFriend("player", "target")',
check = function(value)
return type(value) == "boolean"
end,
},
},
}

ns_llua['lua'][98] = {
type = "commenttest",
title = "Тест 95-3: функция CanAttackTarget",
helpModules = {95, 45, 21},
preloadVars = {
{var = "CanAttackTarget", desc = "CanAttackTarget очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 95-3: функция CanAttackTarget</h>
<t>Создай глобальную функцию <k>CanAttackTarget()</k>.</t>
<t>Функция должна вернуть <k>true</k>, если игрок может атаковать текущую цель.</t>
<t>Иначе функция должна вернуть <k>false</k>.</t>
<t>Используй:</t>
<c>UnitCanAttack("player", "target")</c>
<t>Чтобы результат был именно boolean, используй конструкцию:</t>
<code>
return UnitCanAttack("player", "target") and true or false
</code>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CanAttackTarget()
]=],
requireKeywords = {
"CanAttackTarget",
"function",
"UnitCanAttack",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CanAttackTarget) ~= "function" then
_G.checkError = "CanAttackTarget не является глобальной функцией"
return false
end
local ok, result = pcall(_G.CanAttackTarget)
if not ok then
_G.checkError = "Ошибка вызова CanAttackTarget: " .. tostring(result)
return false
end
if type(result) ~= "boolean" then
_G.checkError = "Функция должна вернуть boolean"
return false
end
return true
end,
}

ns_llua['lua'][99] = {
type = "commenttest",
title = "Тест 95-4: функция GetRelationReport",
helpModules = {95, 45, 44},
preloadVars = {
{var = "GetRelationReport", desc = "GetRelationReport очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 95-4: функция GetRelationReport</h>
<t>Создай глобальную функцию <k>GetRelationReport(unit)</k>.</t>
<t>Функция должна вернуть таблицу с полями:</t>
<c>canAttack</c> — <k>true</k>, если игрок может атаковать юнита, иначе <k>false</k>.
<c>isEnemy</c> — <k>true</k>, если юнит враждебен, иначе <k>false</k>.
<c>isFriend</c> — <k>true</k>, если юнит дружественен, иначе <k>false</k>.
<t>Используй:</t>
<c>UnitCanAttack("player", unit)</c>
<c>UnitIsEnemy("player", unit)</c>
<c>UnitIsFriend("player", unit)</c>
<t>Для boolean-значений используй приведение через <k>and true or false</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetRelationReport(unit)
]=],
requireKeywords = {
"GetRelationReport",
"function",
"UnitCanAttack",
"UnitIsEnemy",
"UnitIsFriend",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetRelationReport) ~= "function" then
_G.checkError = "GetRelationReport не является глобальной функцией"
return false
end
local ok1, playerReport = pcall(_G.GetRelationReport, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetRelationReport('player'): " .. tostring(playerReport)
return false
end
if type(playerReport) ~= "table" then
_G.checkError = "GetRelationReport('player') должна вернуть таблицу"
return false
end
if type(playerReport.canAttack) ~= "boolean" then
_G.checkError = "Поле canAttack должно быть boolean"
return false
end
if type(playerReport.isEnemy) ~= "boolean" then
_G.checkError = "Поле isEnemy должно быть boolean"
return false
end
if type(playerReport.isFriend) ~= "boolean" then
_G.checkError = "Поле isFriend должно быть boolean"
return false
end
local ok2, invalidReport = pcall(_G.GetRelationReport, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetRelationReport('ns_invalid_unit'): " .. tostring(invalidReport)
return false
end
if type(invalidReport) ~= "table" then
_G.checkError = "Для несуществующего юнита функция должна вернуть таблицу"
return false
end
if invalidReport.canAttack ~= false then
_G.checkError = "Для несуществующего юнита поле canAttack должно быть false"
return false
end
if invalidReport.isEnemy ~= false then
_G.checkError = "Для несуществующего юнита поле isEnemy должно быть false"
return false
end
if invalidReport.isFriend ~= false then
_G.checkError = "Для несуществующего юнита поле isFriend должно быть false"
return false
end
return true
end,
}

ns_llua['lua'][100] = {
type = "commenttest",
title = "Тест 95-5: функция IsPvpActive",
helpModules = {95, 45, 21},
preloadVars = {
{var = "IsPvpActive", desc = "IsPvpActive очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 95-5: функция IsPvpActive</h>
<t>Создай глобальную функцию <k>IsPvpActive(unit)</k>.</t>
<t>Функция должна вернуть <k>true</k>, если у юнита включён PvP-флаг.</t>
<t>Иначе функция должна вернуть <k>false</k>.</t>
<t>Используй:</t>
<c>UnitIsPVP</c>
<t>Чтобы результат был именно boolean, используй конструкцию:</t>
<code>
return UnitIsPVP(unit) and true or false
</code>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию IsPvpActive(unit)
]=],
requireKeywords = {
"IsPvpActive",
"function",
"UnitIsPVP",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.IsPvpActive) ~= "function" then
_G.checkError = "IsPvpActive не является глобальной функцией"
return false
end
local ok1, playerPvp = pcall(_G.IsPvpActive, "player")
if not ok1 then
_G.checkError = "Ошибка вызова IsPvpActive('player'): " .. tostring(playerPvp)
return false
end
if type(playerPvp) ~= "boolean" then
_G.checkError = "Для player функция должна вернуть boolean"
return false
end
local ok2, invalidPvp = pcall(_G.IsPvpActive, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова IsPvpActive('ns_invalid_unit'): " .. tostring(invalidPvp)
return false
end
if invalidPvp ~= false then
_G.checkError = "Для несуществующего юнита функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][101] = {
type = "info",
title = "Описание юнита",
helpModules = {77, 83, 95},
content = [=[
<h>Описание юнита</h>
<t>Эти функции возвращают базовое описание юнита: уровень, расу, класс, пол, тип существа.</t>
<h>UnitLevel</h>
<code>
/run print(UnitLevel("player"))
/run print(UnitLevel("target"))
</code>
<w>Особенность:</w> уровень <k>-1</k> часто означает босса.
<h>UnitRace</h>
<code>
/run local race, raceToken = UnitRace("player"); print(race, raceToken)
</code>
<t>Первое значение — локализованное название расы.</t>
<t>Второе значение — технический токен, например <s>HUMAN</s> или <s>ORC</s>.</t>
<h>UnitClass</h>
<code>
/run local className, classToken = UnitClass("player"); print(className, classToken)
</code>
<t>Для логики лучше использовать токен:</t>
<code>
/run local _, token = UnitClass("player"); if token == "MAGE" then print("Маг") end
</code>
<h>UnitSex</h>
<code>
/run print(UnitSex("player"))
</code>
<h>UnitClassification</h>
<t>Возвращает тип сложности существа.</t>
<code>
/run print(UnitClassification("target"))
</code>
<t>Возможные значения:</t>
<c>normal</c>
<c>elite</c>
<c>rare</c>
<c>rareelite</c>
<c>worldboss</c>
<h>UnitCreatureType и UnitCreatureFamily</h>
<code>
/run print(UnitCreatureType("target"))
/run print(UnitCreatureFamily("target"))
</code>
<h>Мини-досье</h>
<code>
/run local name = UnitName("target") or "Нет цели"; local level = UnitLevel("target") or 0; local class = UnitClass("target") or "Неизвестно"; print(string.format("%s, уровень %s, класс %s", name, level, class))
</code>
]=],
}

ns_llua['lua'][102] = {
type = "vartest",
title = "Тест 101-1: уровень и токен класса",
helpModules = {101},
tasks = {
{
var = "myLevel",
desc = 'Создай глобальную переменную myLevel = UnitLevel("player")',
check = function(value)
return type(value) == "number" and value > 0
end,
},
{
var = "myClassToken",
desc = 'Создай глобальную переменную myClassToken = select(2, UnitClass("player"))',
check = function(value)
return type(value) == "string"
and value ~= ""
and value == value:upper()
end,
},
},
}

ns_llua['lua'][103] = {
type = "vartest",
title = "Тест 101-2: раса и классификация",
helpModules = {101},
tasks = {
{
var = "myRaceToken",
desc = 'Создай глобальную переменную myRaceToken = select(2, UnitRace("player"))',
check = function(value)
return type(value) == "string"
and value ~= ""
and value == value:upper()
end,
},
{
var = "playerClassification",
desc = 'Создай глобальную переменную playerClassification = UnitClassification("player") or "unknown"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][104] = {
type = "commenttest",
title = "Тест 101-3: функция GetClassToken",
helpModules = {101, 45},
preloadVars = {
{var = "GetClassToken", desc = "GetClassToken очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 101-3: функция GetClassToken</h>
<t>Создай глобальную функцию <k>GetClassToken(unit)</k>.</t>
<t>Функция должна вернуть токен класса юнита.</t>
<t>Используй:</t>
<c>UnitClass(unit)</c>
<c>select(2, ...)</c>
<t>Если токен получить нельзя, функция может вернуть <k>nil</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetClassToken(unit)
]=],
requireKeywords = {
"GetClassToken",
"function",
"UnitClass",
"select",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetClassToken) ~= "function" then
_G.checkError = "GetClassToken не является глобальной функцией"
return false
end
local ok1, playerToken = pcall(_G.GetClassToken, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetClassToken('player'): " .. tostring(playerToken)
return false
end
if type(playerToken) ~= "string" or playerToken == "" then
_G.checkError = "Для player функция должна вернуть строку с токеном класса"
return false
end
local ok2, invalidToken = pcall(_G.GetClassToken, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetClassToken('ns_invalid_unit'): " .. tostring(invalidToken)
return false
end
if invalidToken ~= nil then
_G.checkError = "Для несуществующего юнита функция должна вернуть nil"
return false
end
return true
end,
}

ns_llua['lua'][105] = {
type = "commenttest",
title = "Тест 101-4: функция GetLevelSafe",
helpModules = {101, 65, 45},
preloadVars = {
{var = "GetLevelSafe", desc = "GetLevelSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 101-4: функция GetLevelSafe</h>
<t>Создай глобальную функцию <k>GetLevelSafe(unit)</k>.</t>
<t>Если юнита не существует, функция должна вернуть <n>0</n>.</t>
<t>Если юнит существует, функция должна вернуть его уровень через <k>UnitLevel(unit)</k>.</t>
<t>Если <k>UnitLevel</k> вернул <k>nil</k>, используй <k>or 0</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetLevelSafe(unit)
]=],
requireKeywords = {
"GetLevelSafe",
"function",
"UnitExists",
"UnitLevel",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetLevelSafe) ~= "function" then
_G.checkError = "GetLevelSafe не является глобальной функцией"
return false
end
local ok1, playerLevel = pcall(_G.GetLevelSafe, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetLevelSafe('player'): " .. tostring(playerLevel)
return false
end
if type(playerLevel) ~= "number" or playerLevel <= 0 then
_G.checkError = "Для player функция должна вернуть число больше нуля"
return false
end
local ok2, invalidLevel = pcall(_G.GetLevelSafe, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetLevelSafe('ns_invalid_unit'): " .. tostring(invalidLevel)
return false
end
if invalidLevel ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][106] = {
type = "commenttest",
title = "Тест 101-5: функция GetDescription",
helpModules = {101, 45, 44},
preloadVars = {
{var = "GetDescription", desc = "GetDescription очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 101-5: функция GetDescription</h>
<t>Создай глобальную функцию <k>GetDescription(unit)</k>.</t>
<t>Функция должна вернуть таблицу с полями:</t>
<c>level</c> — уровень юнита или <n>0</n>, если юнита нет.
<c>classToken</c> — токен класса или <k>nil</k>, если получить нельзя.
<c>raceToken</c> — токен расы или <k>nil</k>, если получить нельзя.
<t>Используй:</t>
<c>UnitExists</c>
<c>UnitLevel</c>
<c>UnitClass</c>
<c>UnitRace</c>
<c>select(2, ...)</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetDescription(unit)
]=],
requireKeywords = {
"GetDescription",
"function",
"UnitExists",
"UnitLevel",
"UnitClass",
"UnitRace",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetDescription) ~= "function" then
_G.checkError = "GetDescription не является глобальной функцией"
return false
end
local ok1, playerReport = pcall(_G.GetDescription, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetDescription('player'): " .. tostring(playerReport)
return false
end
if type(playerReport) ~= "table" then
_G.checkError = "GetDescription('player') должна вернуть таблицу"
return false
end
if type(playerReport.level) ~= "number" or playerReport.level <= 0 then
_G.checkError = "Для player поле level должно быть числом больше нуля"
return false
end
if type(playerReport.classToken) ~= "string" or playerReport.classToken == "" then
_G.checkError = "Для player поле classToken должно быть строкой"
return false
end
if type(playerReport.raceToken) ~= "string" or playerReport.raceToken == "" then
_G.checkError = "Для player поле raceToken должно быть строкой"
return false
end
local ok2, invalidReport = pcall(_G.GetDescription, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetDescription('ns_invalid_unit'): " .. tostring(invalidReport)
return false
end
if type(invalidReport) ~= "table" then
_G.checkError = "Для несуществующего юнита функция должна вернуть таблицу"
return false
end
if invalidReport.level ~= 0 then
_G.checkError = "Для несуществующего юнита поле level должно быть 0"
return false
end
if invalidReport.classToken ~= nil then
_G.checkError = "Для несуществующего юнита поле classToken должно быть nil"
return false
end
if invalidReport.raceToken ~= nil then
_G.checkError = "Для несуществующего юнита поле raceToken должно быть nil"
return false
end
return true
end,
}

ns_llua['lua'][107] = {
type = "info",
title = "Баффы и дебаффы как данные",
helpModules = {101, 31, 33},
content = [=[
<h>Баффы и дебаффы как данные</h>
<t>Баффы и дебаффы в WoW API обычно перебираются по индексу: 1, 2, 3 и так далее.</t>
<h>UnitBuff</h>
<code>
/run local name = UnitBuff("player", 1); print(name)
</code>
<t>Если баффа с таким индексом нет, функция вернёт <k>nil</k>.</t>
<h>UnitDebuff</h>
<code>
/run local name = UnitDebuff("player", 1); print(name)
</code>
<h>UnitAura</h>
<t>Более универсальная функция. Она может искать и баффы, и дебаффы.</t>
<code>
/run local name = UnitAura("player", 1, "HELPFUL"); print(name)
</code>
<c>"HELPFUL"</c> — баффы.
<c>"HARMFUL"</c> — дебаффы.
<h>Несколько возвращаемых значений</h>
<t>Функции аур возвращают много данных: имя, иконку, количество стаков, тип, длительность и время окончания.</t>
<code>
/run local name, _, _, count = UnitBuff("player", 1); print(name, count)
</code>
<h>Подсчёт баффов</h>
<code>
/run local count = 0; local i = 1; while UnitBuff("player", i) do count = count + 1; i = i + 1 end; print("Баффов:", count)
</code>
<h>Остаток времени</h>
<code>
/run local name, _, _, _, _, duration, expiration = UnitBuff("player", 1); if name and expiration and expiration > 0 then print(name, math.floor(expiration - GetTime())) end
</code>
<t>Если <k>duration</k> и <k>expirationTime</k> равны нулю, таймер у ауры может отсутствовать.</t>
<h>Поиск баффа по имени</h>
<code>
/run local found = false; for i = 1, 40 do local name = UnitBuff("player", i); if not name then break end; if string.find(name, "Бафф") then found = true end end; print(found)
</code>
<w>Важно:</w> точное имя баффа зависит от языка клиента. Поэтому в реальных аддонах часто используют spellID, если он доступен.
]=],
}

ns_llua['lua'][108] = {
type = "commenttest",
title = "Тест 107-1: функция CountUnitBuffs",
helpModules = {107, 45, 32},
preloadVars = {
{var = "CountUnitBuffs", desc = "CountUnitBuffs очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 107-1: функция CountUnitBuffs</h>
<t>Создай глобальную функцию <k>CountUnitBuffs(unit)</k>.</t>
<t>Функция должна вернуть количество баффов на юните.</t>
<t>Используй <k>UnitBuff(unit, index)</k>.</t>
<t>Перебирай индексы, пока функция не вернёт <k>nil</k>.</t>
<t>Для несуществующего юнита функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountUnitBuffs(unit)
]=],
requireKeywords = {
"CountUnitBuffs",
"function",
"UnitBuff",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountUnitBuffs) ~= "function" then
_G.checkError = "CountUnitBuffs не является глобальной функцией"
return false
end
local ok1, playerCount = pcall(_G.CountUnitBuffs, "player")
if not ok1 then
_G.checkError = "Ошибка вызова CountUnitBuffs('player'): " .. tostring(playerCount)
return false
end
if type(playerCount) ~= "number" or playerCount < 0 then
_G.checkError = "Для player функция должна вернуть число больше или равное нулю"
return false
end
local ok2, invalidCount = pcall(_G.CountUnitBuffs, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова CountUnitBuffs('ns_invalid_unit'): " .. tostring(invalidCount)
return false
end
if invalidCount ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][109] = {
type = "commenttest",
title = "Тест 107-2: функция CountUnitDebuffs",
helpModules = {107, 45, 32},
preloadVars = {
{var = "CountUnitDebuffs", desc = "CountUnitDebuffs очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 107-2: функция CountUnitDebuffs</h>
<t>Создай глобальную функцию <k>CountUnitDebuffs(unit)</k>.</t>
<t>Функция должна вернуть количество дебаффов на юните.</t>
<t>Используй <k>UnitDebuff(unit, index)</k>.</t>
<t>Перебирай индексы, пока функция не вернёт <k>nil</k>.</t>
<t>Для несуществующего юнита функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountUnitDebuffs(unit)
]=],
requireKeywords = {
"CountUnitDebuffs",
"function",
"UnitDebuff",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountUnitDebuffs) ~= "function" then
_G.checkError = "CountUnitDebuffs не является глобальной функцией"
return false
end
local ok1, playerCount = pcall(_G.CountUnitDebuffs, "player")
if not ok1 then
_G.checkError = "Ошибка вызова CountUnitDebuffs('player'): " .. tostring(playerCount)
return false
end
if type(playerCount) ~= "number" or playerCount < 0 then
_G.checkError = "Для player функция должна вернуть число больше или равное нулю"
return false
end
local ok2, invalidCount = pcall(_G.CountUnitDebuffs, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова CountUnitDebuffs('ns_invalid_unit'): " .. tostring(invalidCount)
return false
end
if invalidCount ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][110] = {
type = "commenttest",
title = "Тест 107-3: функция GetAuraName",
helpModules = {107, 65, 45},
preloadVars = {
{var = "GetAuraName", desc = "GetAuraName очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 107-3: функция GetAuraName</h>
<t>Создай глобальную функцию <k>GetAuraName(unit, index)</k>.</t>
<t>Функция должна вернуть имя баффа через <k>UnitBuff(unit, index)</k>.</t>
<t>Если баффа нет, функция должна вернуть строку:</t>
<s>"нет"</s>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetAuraName(unit, index)
]=],
requireKeywords = {
"GetAuraName",
"function",
"UnitBuff",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetAuraName) ~= "function" then
_G.checkError = "GetAuraName не является глобальной функцией"
return false
end
local ok1, playerName = pcall(_G.GetAuraName, "player", 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetAuraName('player', 1): " .. tostring(playerName)
return false
end
if type(playerName) ~= "string" or playerName == "" then
_G.checkError = "Функция должна вернуть строку"
return false
end
local ok2, invalidName = pcall(_G.GetAuraName, "ns_invalid_unit", 1)
if not ok2 then
_G.checkError = "Ошибка вызова GetAuraName('ns_invalid_unit', 1): " .. tostring(invalidName)
return false
end
if invalidName ~= "нет" then
_G.checkError = "Для несуществующего юнита функция должна вернуть 'нет'"
return false
end
return true
end,
}

ns_llua['lua'][111] = {
type = "commenttest",
title = "Тест 107-4: функция HasAuraWithName",
helpModules = {107, 33, 45, 31},
preloadVars = {
{var = "HasAuraWithName", desc = "HasAuraWithName очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 107-4: функция HasAuraWithName</h>
<t>Создай глобальную функцию <k>HasAuraWithName(unit, text)</k>.</t>
<t>Функция должна вернуть <k>true</k>, если среди баффов юнита есть бафф, в названии которого есть подстрока <k>text</k>.</t>
<t>Иначе функция должна вернуть <k>false</k>.</t>
<t>Используй:</t>
<c>UnitBuff</c>
<c>string.find</c>
<t>Если <k>text</k> не строка или пустая строка, верни <k>false</k>.</t>
<t>Проверяй баффы с индексами от 1 до 40.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию HasAuraWithName(unit, text)
]=],
requireKeywords = {
"HasAuraWithName",
"function",
"UnitBuff",
"string.find",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.HasAuraWithName) ~= "function" then
_G.checkError = "HasAuraWithName не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.HasAuraWithName, "player", "zzz_no_such_aura_zzz")
if not ok1 then
_G.checkError = "Ошибка вызова HasAuraWithName('player', ...): " .. tostring(result1)
return false
end
if result1 ~= false then
_G.checkError = "Для несуществующей подстроки функция должна вернуть false"
return false
end
local ok2, result2 = pcall(_G.HasAuraWithName, "ns_invalid_unit", "zzz_no_such_aura_zzz")
if not ok2 then
_G.checkError = "Ошибка вызова HasAuraWithName('ns_invalid_unit', ...): " .. tostring(result2)
return false
end
if result2 ~= false then
_G.checkError = "Для несуществующего юнита функция должна вернуть false"
return false
end
local ok3, result3 = pcall(_G.HasAuraWithName, "player", "")
if not ok3 then
_G.checkError = "Ошибка вызова HasAuraWithName('player', ''): " .. tostring(result3)
return false
end
if result3 ~= false then
_G.checkError = "Для пустой строки функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][112] = {
type = "commenttest",
title = "Тест 107-5: функция GetBuffList",
helpModules = {107, 44, 45, 31},
preloadVars = {
{var = "GetBuffList", desc = "GetBuffList очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 107-5: функция GetBuffList</h>
<t>Создай глобальную функцию <k>GetBuffList(unit, max)</k>.</t>
<t>Функция должна вернуть таблицу с именами баффов юнита.</t>
<t>Собери не больше <k>max</k> баффов.</t>
<t>Если бафф не найден, прекрати перебор.</t>
<t>Если <k>max</k> не число или меньше либо равно нулю, верни пустую таблицу.</t>
<t>Используй:</t>
<c>UnitBuff</c>
<c>table.insert</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetBuffList(unit, max)
]=],
requireKeywords = {
"GetBuffList",
"function",
"UnitBuff",
"table.insert",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetBuffList) ~= "function" then
_G.checkError = "GetBuffList не является глобальной функцией"
return false
end
local ok1, playerList = pcall(_G.GetBuffList, "player", 5)
if not ok1 then
_G.checkError = "Ошибка вызова GetBuffList('player', 5): " .. tostring(playerList)
return false
end
if type(playerList) ~= "table" then
_G.checkError = "GetBuffList('player', 5) должна вернуть таблицу"
return false
end
if #playerList > 5 then
_G.checkError = "Функция не должна возвращать больше баффов, чем max"
return false
end
for i, name in ipairs(playerList) do
if type(name) ~= "string" or name == "" then
_G.checkError = "Каждый элемент списка баффов должен быть строкой"
return false
end
end
local ok2, invalidList = pcall(_G.GetBuffList, "ns_invalid_unit", 5)
if not ok2 then
_G.checkError = "Ошибка вызова GetBuffList('ns_invalid_unit', 5): " .. tostring(invalidList)
return false
end
if type(invalidList) ~= "table" or #invalidList ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть пустую таблицу"
return false
end
local ok3, badMaxList = pcall(_G.GetBuffList, "player", 0)
if not ok3 then
_G.checkError = "Ошибка вызова GetBuffList('player', 0): " .. tostring(badMaxList)
return false
end
if type(badMaxList) ~= "table" or #badMaxList ~= 0 then
_G.checkError = "Для max = 0 функция должна вернуть пустую таблицу"
return false
end
return true
end,
}

ns_llua['lua'][113] = {
type = "info",
title = "Группа: party1-party4",
helpModules = {71, 101},
content = [=[
<h>Группа: party1-party4</h>
<t>В группе может быть до четырёх других игроков. Их UnitID:</t>
<c>"party1"</c>
<c>"party2"</c>
<c>"party3"</c>
<c>"party4"</c>
<h>Количество участников группы</h>
<code>
/run print(GetNumPartyMembers())
</code>
<t>Если ты не в группе, функция обычно возвращает <n>0</n>.</t>
<h>Перебор группы</h>
<code>
/run for i = 1, 4 do local unit = "party" .. i; if UnitExists(unit) then print(UnitName(unit)) end end
</code>
<t>Здесь строка <s>"party"</s> склеивается с числом <k>i</k>, получаются <s>"party1"</s>, <s>"party2"</s> и так далее.</t>
<h>Лидер группы</h>
<code>
/run print(GetPartyLeaderIndex())
</code>
<t>Если лидер — первый участник группы, функция может вернуть <n>1</n>.</t>
<t>Если ты один или лидером являешься ты, функция может вернуть <n>0</n> или <k>nil</k>.</t>
<h>Проверка лидера</h>
<code>
/run local leader = GetPartyLeaderIndex(); if leader and leader > 0 then print("Лидер группы: party" .. leader) else print("Лидер не найден или ты один") end
</code>
<h>UnitInParty</h>
<code>
/run print(UnitInParty("player"))
</code>
<h>Таблица участников</h>
<code>
/run partyReport = {}; for i = 1, 4 do local unit = "party" .. i; if UnitExists(unit) then table.insert(partyReport, UnitName(unit)) end end; print("В группе:", #partyReport)
</code>
<w>Примечание:</w> если ты в рейде, используются UnitID <c>"raid1"</c> — <c>"raid40"</c>, а не <c>"party"</c>.
]=],
}

ns_llua['lua'][114] = {
type = "vartest",
title = "Тест 113-1: количество участников группы",
helpModules = {113},
tasks = {
{
var = "partyCount",
desc = 'Создай глобальную переменную partyCount = GetNumPartyMembers() or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 4
end,
},
},
}

ns_llua['lua'][115] = {
type = "vartest",
title = "Тест 113-2: таблица party-юнитов",
helpModules = {113, 44},
tasks = {
{
var = "partyUnits",
desc = 'Создай глобальную таблицу partyUnits = {"party1", "party2", "party3", "party4"}',
check = function(value)
return type(value) == "table"
and #value == 4
and value[1] == "party1"
and value[2] == "party2"
and value[3] == "party3"
and value[4] == "party4"
end,
},
},
}

ns_llua['lua'][116] = {
type = "commenttest",
title = "Тест 113-3: функция GetPartyUnitList",
helpModules = {113, 45},
preloadVars = {
{var = "GetPartyUnitList", desc = "GetPartyUnitList очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 113-3: функция GetPartyUnitList</h>
<t>Создай глобальную функцию <k>GetPartyUnitList()</k>.</t>
<t>Функция должна вернуть таблицу из четырёх строк:</t>
<c>"party1"</c>
<c>"party2"</c>
<c>"party3"</c>
<c>"party4"</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetPartyUnitList()
]=],
requireKeywords = {
"GetPartyUnitList",
"function",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetPartyUnitList) ~= "function" then
_G.checkError = "GetPartyUnitList не является глобальной функцией"
return false
end
local ok, list = pcall(_G.GetPartyUnitList)
if not ok then
_G.checkError = "Ошибка вызова GetPartyUnitList: " .. tostring(list)
return false
end
if type(list) ~= "table" then
_G.checkError = "GetPartyUnitList должна вернуть таблицу"
return false
end
if #list ~= 4 then
_G.checkError = "В таблице должно быть 4 элемента"
return false
end
if list[1] ~= "party1" or list[2] ~= "party2" or list[3] ~= "party3" or list[4] ~= "party4" then
_G.checkError = "Таблица должна содержать party1, party2, party3, party4"
return false
end
return true
end,
}

ns_llua['lua'][117] = {
type = "commenttest",
title = "Тест 113-4: функция CountExistingPartyMembers",
helpModules = {113, 45, 31},
preloadVars = {
{var = "CountExistingPartyMembers", desc = "CountExistingPartyMembers очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 113-4: функция CountExistingPartyMembers</h>
<t>Создай глобальную функцию <k>CountExistingPartyMembers()</k>.</t>
<t>Функция должна вернуть количество существующих участников группы.</t>
<t>Проверь юниты:</t>
<c>"party1"</c>
<c>"party2"</c>
<c>"party3"</c>
<c>"party4"</c>
<t>Используй цикл и <k>UnitExists</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountExistingPartyMembers()
]=],
requireKeywords = {
"CountExistingPartyMembers",
"function",
"UnitExists",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountExistingPartyMembers) ~= "function" then
_G.checkError = "CountExistingPartyMembers не является глобальной функцией"
return false
end
local ok, count = pcall(_G.CountExistingPartyMembers)
if not ok then
_G.checkError = "Ошибка вызова CountExistingPartyMembers: " .. tostring(count)
return false
end
if type(count) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if count < 0 or count > 4 then
_G.checkError = "Количество участников группы должно быть от 0 до 4"
return false
end
return true
end,
}

ns_llua['lua'][118] = {
type = "commenttest",
title = "Тест 113-5: функция GetPartyLeaderUnit",
helpModules = {113, 45, 17},
preloadVars = {
{var = "GetPartyLeaderUnit", desc = "GetPartyLeaderUnit очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 113-5: функция GetPartyLeaderUnit</h>
<t>Создай глобальную функцию <k>GetPartyLeaderUnit()</k>.</t>
<t>Функция должна вернуть строку с UnitID лидера группы.</t>
<t>Используй <k>GetPartyLeaderIndex()</k>.</t>
<t>Если индекс лидера больше нуля, верни строку вида:</t>
<s>"party1"</s>
<s>"party2"</s>
<s>"party3"</s>
<s>"party4"</s>
<t>Если лидера нет или индекс меньше либо равен нулю, верни строку:</t>
<s>"none"</s>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetPartyLeaderUnit()
]=],
requireKeywords = {
"GetPartyLeaderUnit",
"function",
"GetPartyLeaderIndex",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetPartyLeaderUnit) ~= "function" then
_G.checkError = "GetPartyLeaderUnit не является глобальной функцией"
return false
end
local ok, leaderUnit = pcall(_G.GetPartyLeaderUnit)
if not ok then
_G.checkError = "Ошибка вызова GetPartyLeaderUnit: " .. tostring(leaderUnit)
return false
end
if type(leaderUnit) ~= "string" then
_G.checkError = "Функция должна вернуть строку"
return false
end
local valid = {
none = true,
party1 = true,
party2 = true,
party3 = true,
party4 = true,
}
if not valid[leaderUnit] then
_G.checkError = "Функция должна вернуть none или party1-party4"
return false
end
return true
end,
}

ns_llua['lua'][119] = {
type = "info",
title = "Рейд: raid1-raid40",
helpModules = {113, 71},
content = [=[
<h>Рейд: raid1-raid40</h>
<t>Если игрок находится в рейде, участники доступны через UnitID:</t>
<c>"raid1"</c>
<c>"raid2"</c>
<c>"raid3"</c>
<c>...</c>
<c>"raid40"</c>
<h>Количество участников рейда</h>
<code>
/run print(GetNumRaidMembers())
</code>
<t>Если ты не в рейде, функция обычно возвращает <n>0</n>.</t>
<h>Перебор рейда</h>
<code>
/run local count = GetNumRaidMembers() or 0; for i = 1, count do local unit = "raid" .. i; if UnitExists(unit) then print(UnitName(unit)) end end
</code>
<t>Здесь строка <s>"raid"</s> склеивается с числом <k>i</k>, получаются <s>"raid1"</s>, <s>"raid2"</s> и так далее.</t>
<h>GetRaidRosterInfo</h>
<t>Функция возвращает информацию об участнике рейда по индексу.</t>
<code>
/run local name, rank, subgroup, level, class = GetRaidRosterInfo(1); print(name, subgroup, level, class)
</code>
<t>Если игрок не в рейде или индекс неверный, значения могут быть <k>nil</k>.</t>
<h>Таблица имён рейда</h>
<code>
/run raidNames = {}; local count = GetNumRaidMembers() or 0; for i = 1, count do local name = GetRaidRosterInfo(i); if name then table.insert(raidNames, name) end end; print("В рейде:", #raidNames)
</code>
<w>Важно:</w> в рейде не нужно использовать <c>"party1"</c> — <c>"party4"</c>. Для рейда используются <c>"raid1"</c> — <c>"raid40"</c>.
<h>Безопасный шаблон</h>
<code>
/run local count = GetNumRaidMembers() or 0; if count > 0 then print("Рейд найден") else print("Рейда нет") end
</code>
]=],
}

ns_llua['lua'][120] = {
type = "vartest",
title = "Тест 119-1: количество участников рейда",
helpModules = {119, 65},
tasks = {
{
var = "raidCount",
desc = 'Создай глобальную переменную raidCount = GetNumRaidMembers() or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 40
end,
},
},
}

ns_llua['lua'][121] = {
type = "vartest",
title = "Тест 119-2: строки raid-юнитов",
helpModules = {119, 71},
tasks = {
{
var = "raidUnitPrefix",
desc = 'Создай глобальную переменную raidUnitPrefix = "raid"',
check = function(value)
return value == "raid"
end,
},
{
var = "raidUnit1",
desc = 'Создай глобальную переменную raidUnit1 = "raid1"',
check = function(value)
return value == "raid1"
end,
},
{
var = "raidUnit40",
desc = 'Создай глобальную переменную raidUnit40 = "raid40"',
check = function(value)
return value == "raid40"
end,
},
},
}

ns_llua['lua'][122] = {
type = "commenttest",
title = "Тест 119-3: функция GetRaidUnit",
helpModules = {119, 45, 17},
preloadVars = {
{var = "GetRaidUnit", desc = "GetRaidUnit очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 119-3: функция GetRaidUnit</h>
<t>Создай глобальную функцию <k>GetRaidUnit(index)</k>.</t>
<t>Если <k>index</k> — целое число от 1 до 40, функция должна вернуть строку вида:</t>
<s>"raid1"</s>
<s>"raid2"</s>
<s>"raid40"</s>
<t>Во всех остальных случаях функция должна вернуть строку:</t>
<s>"invalid"</s>
<t>Используй:</t>
<c>type</c>
<c>math.floor</c>
<c>конкатенацию</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetRaidUnit(index)
]=],
requireKeywords = {
"GetRaidUnit",
"function",
"type",
"math.floor",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetRaidUnit) ~= "function" then
_G.checkError = "GetRaidUnit не является глобальной функцией"
return false
end
local tests = {
{input = 1, expected = "raid1"},
{input = 40, expected = "raid40"},
{input = 0, expected = "invalid"},
{input = 41, expected = "invalid"},
{input = "bad", expected = "invalid"},
{input = 1.5, expected = "invalid"},
}
for i, test in ipairs(tests) do
local ok, result = pcall(_G.GetRaidUnit, test.input)
if not ok or result ~= test.expected then
_G.checkError = "Тест " .. i .. " функции GetRaidUnit не пройден"
return false
end
end
return true
end,
}

ns_llua['lua'][123] = {
type = "commenttest",
title = "Тест 119-4: функция CountExistingRaidMembers",
helpModules = {119, 45, 31},
preloadVars = {
{var = "CountExistingRaidMembers", desc = "CountExistingRaidMembers очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 119-4: функция CountExistingRaidMembers</h>
<t>Создай глобальную функцию <k>CountExistingRaidMembers()</k>.</t>
<t>Функция должна вернуть количество существующих участников рейда.</t>
<t>Проверь юниты от <c>"raid1"</c> до <c>"raid40"</c>.</t>
<t>Используй цикл и <k>UnitExists</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountExistingRaidMembers()
]=],
requireKeywords = {
"CountExistingRaidMembers",
"function",
"UnitExists",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountExistingRaidMembers) ~= "function" then
_G.checkError = "CountExistingRaidMembers не является глобальной функцией"
return false
end
local ok, count = pcall(_G.CountExistingRaidMembers)
if not ok then
_G.checkError = "Ошибка вызова CountExistingRaidMembers: " .. tostring(count)
return false
end
if type(count) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if count < 0 or count > 40 then
_G.checkError = "Количество участников рейда должно быть от 0 до 40"
return false
end
return true
end,
}

ns_llua['lua'][124] = {
type = "commenttest",
title = "Тест 119-5: функция GetRaidMemberName",
helpModules = {119, 65, 77},
preloadVars = {
{var = "GetRaidMemberName", desc = "GetRaidMemberName очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 119-5: функция GetRaidMemberName</h>
<t>Создай глобальную функцию <k>GetRaidMemberName(index)</k>.</t>
<t>Если <k>index</k> не является целым числом от 1 до 40, функция должна вернуть строку:</t>
<s>"Нет участника"</s>
<t>Иначе функция должна вернуть имя участника рейда через:</t>
<code>
UnitName("raid" .. index)
</code>
<t>Если имени нет, функция должна вернуть строку:</t>
<s>"Нет участника"</s>
<t>Используй:</t>
<c>type</c>
<c>math.floor</c>
<c>UnitName</c>
<c>or</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetRaidMemberName(index)
]=],
requireKeywords = {
"GetRaidMemberName",
"function",
"type",
"math.floor",
"UnitName",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetRaidMemberName) ~= "function" then
_G.checkError = "GetRaidMemberName не является глобальной функцией"
return false
end
local ok1, invalid1 = pcall(_G.GetRaidMemberName, 0)
if not ok1 or invalid1 ~= "Нет участника" then
_G.checkError = "Для index = 0 функция должна вернуть 'Нет участника'"
return false
end
local ok2, invalid2 = pcall(_G.GetRaidMemberName, 41)
if not ok2 or invalid2 ~= "Нет участника" then
_G.checkError = "Для index = 41 функция должна вернуть 'Нет участника'"
return false
end
local ok3, first = pcall(_G.GetRaidMemberName, 1)
if not ok3 then
_G.checkError = "Ошибка вызова GetRaidMemberName(1): " .. tostring(first)
return false
end
if type(first) ~= "string" or first == "" then
_G.checkError = "Для index = 1 функция должна вернуть строку"
return false
end
return true
end,
}

ns_llua['lua'][125] = {
type = "info",
title = "Лидерство, роли и лут",
helpModules = {113, 119},
content = [=[
<h>Лидерство, роли и лут</h>
<t>Эти функции помогают понять, кто главный в группе или рейде, а также как распределяется добыча.</t>
<h>Лидер группы</h>
<code>
/run print(GetPartyLeaderIndex())
</code>
<t>Если лидер группы — первый участник, функция может вернуть <n>1</n>.</t>
<t>Если ты один или лидером являешься ты, функция может вернуть <n>0</n> или <k>nil</k>.</t>
<h>Лидер рейда</h>
<code>
/run print(GetRaidLeaderIndex())
</code>
<h>Проверка лидера группы</h>
<code>
/run local leader = GetPartyLeaderIndex(); if leader and leader > 0 then print("Лидер группы: party" .. leader) else print("Лидер не найден") end
</code>
<h>UnitIsPartyLeader</h>
<code>
/run print(UnitIsPartyLeader("player"))
</code>
<h>UnitIsRaidOfficer</h>
<t>Проверяет, является ли юнит помощником лидера рейда.</t>
<code>
/run print(UnitIsRaidOfficer("player"))
</code>
<h>Метод распределения лута</h>
<code>
/run local method, master, threshold = GetLootMethod(); print(method, master, threshold)
</code>
<t>Первое значение — строка с методом лута, например:</t>
<c>"freeforall"</c>
<c>"roundrobin"</c>
<c>"master"</c>
<c>"group"</c>
<c>"needbeforegreed"</c>
<h>Порог качества лута</h>
<code>
/run local method, master, threshold = GetLootMethod(); print("Порог:", threshold)
</code>
<w>Примечание:</w> числовое значение порога связано с качеством предмета. Чем выше число, тем выше минимальное качество для розыгрыша.
<h>Безопасный шаблон</h>
<code>
/run local method = GetLootMethod() or "unknown"; print("Метод лута:", method)
</code>
]=],
}

ns_llua['lua'][126] = {
type = "vartest",
title = "Тест 125-1: индексы лидеров",
helpModules = {125, 65},
tasks = {
{
var = "partyLeaderIndex",
desc = 'Создай глобальную переменную partyLeaderIndex = GetPartyLeaderIndex() or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 4
end,
},
{
var = "raidLeaderIndex",
desc = 'Создай глобальную переменную raidLeaderIndex = GetRaidLeaderIndex() or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 40
end,
},
},
}

ns_llua['lua'][127] = {
type = "vartest",
title = "Тест 125-2: метод лута",
helpModules = {125, 65},
tasks = {
{
var = "lootMethod",
desc = 'Создай глобальную переменную lootMethod = GetLootMethod() or "unknown"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "lootThreshold",
desc = 'Создай глобальную переменную lootThreshold = select(3, GetLootMethod()) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][128] = {
type = "commenttest",
title = "Тест 125-3: функция GetPartyLeaderIndexSafe",
helpModules = {125, 45, 65},
preloadVars = {
{var = "GetPartyLeaderIndexSafe", desc = "GetPartyLeaderIndexSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 125-3: функция GetPartyLeaderIndexSafe</h>
<t>Создай глобальную функцию <k>GetPartyLeaderIndexSafe()</k>.</t>
<t>Функция должна вернуть индекс лидера группы через <k>GetPartyLeaderIndex()</k>.</t>
<t>Если индекс не существует или меньше либо равен нулю, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetPartyLeaderIndexSafe()
]=],
requireKeywords = {
"GetPartyLeaderIndexSafe",
"function",
"GetPartyLeaderIndex",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetPartyLeaderIndexSafe) ~= "function" then
_G.checkError = "GetPartyLeaderIndexSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetPartyLeaderIndexSafe)
if not ok then
_G.checkError = "Ошибка вызова GetPartyLeaderIndexSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 or result > 4 then
_G.checkError = "Индекс лидера группы должен быть от 0 до 4"
return false
end
return true
end,
}

ns_llua['lua'][129] = {
type = "commenttest",
title = "Тест 125-4: функция GetRaidLeaderIndexSafe",
helpModules = {125, 45, 65},
preloadVars = {
{var = "GetRaidLeaderIndexSafe", desc = "GetRaidLeaderIndexSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 125-4: функция GetRaidLeaderIndexSafe</h>
<t>Создай глобальную функцию <k>GetRaidLeaderIndexSafe()</k>.</t>
<t>Функция должна вернуть индекс лидера рейда через <k>GetRaidLeaderIndex()</k>.</t>
<t>Если индекс не существует или меньше либо равен нулю, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetRaidLeaderIndexSafe()
]=],
requireKeywords = {
"GetRaidLeaderIndexSafe",
"function",
"GetRaidLeaderIndex",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetRaidLeaderIndexSafe) ~= "function" then
_G.checkError = "GetRaidLeaderIndexSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetRaidLeaderIndexSafe)
if not ok then
_G.checkError = "Ошибка вызова GetRaidLeaderIndexSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 or result > 40 then
_G.checkError = "Индекс лидера рейда должен быть от 0 до 40"
return false
end
return true
end,
}

ns_llua['lua'][130] = {
type = "commenttest",
title = "Тест 125-5: функция GetLootMethodSafe",
helpModules = {125, 45, 65},
preloadVars = {
{var = "GetLootMethodSafe", desc = "GetLootMethodSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 125-5: функция GetLootMethodSafe</h>
<t>Создай глобальную функцию <k>GetLootMethodSafe()</k>.</t>
<t>Функция должна вернуть метод распределения лута через <k>GetLootMethod()</k>.</t>
<t>Если метод не является непустой строкой, функция должна вернуть строку:</t>
<s>"unknown"</s>
<t>Используй:</t>
<c>GetLootMethod</c>
<c>type</c>
<c>return</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetLootMethodSafe()
]=],
requireKeywords = {
"GetLootMethodSafe",
"function",
"GetLootMethod",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetLootMethodSafe) ~= "function" then
_G.checkError = "GetLootMethodSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetLootMethodSafe)
if not ok then
_G.checkError = "Ошибка вызова GetLootMethodSafe: " .. tostring(result)
return false
end
if type(result) ~= "string" or result == "" then
_G.checkError = "Функция должна вернуть непустую строку"
return false
end
return true
end,
}

ns_llua['lua'][131] = {
type = "info",
title = "Гильдия",
helpModules = {113, 65},
content = [=[
<h>Гильдия</h>
<t>WoW API позволяет получать информацию о гильдии игрока.</t>
<h>GetGuildInfo</h>
<code>
/run local guildName, guildRankName = GetGuildInfo("player"); print(guildName or "Без гильдии", guildRankName or "")
</code>
<t>Если игрок не состоит в гильдии, <k>guildName</k> может быть <k>nil</k>.</t>
<h>Количество участников гильдии</h>
<code>
/run local total, online = GetNumGuildMembers(); print(total, online)
</code>
<t>Первое значение — всего участников, второе — онлайн.</t>
<w>Важно:</w> данные гильдии могут быть доступны не мгновенно. Иногда они подгружаются после открытия окна гильдии или после запроса ростера.
<h>GetGuildRosterInfo</h>
<code>
/run local name, rank, rankIndex, level = GetGuildRosterInfo(1); print(name, rank, rankIndex, level)
</code>
<t>Функция возвращает данные участника гильдии по индексу.</t>
<h>Безопасный пример</h>
<code>
/run local guildName = GetGuildInfo("player"); if guildName then print("Гильдия:", guildName) else print("Игрок без гильдии") end
</code>
<h>Таблица участников</h>
<code>
/run guildOnline = {}; local total, online = GetNumGuildMembers(); if online then for i = 1, online do local name = GetGuildRosterInfo(i); if name then table.insert(guildOnline, name) end end end; print("Онлайн:", #guildOnline)
</code>
<w>Примечание:</w> если ростер гильдии ещё не загружен, значения могут быть <k>nil</k>. Позже, в модуле событий, мы научимся обновлять такие данные по событию.
<h>Безопасные значения по умолчанию</h>
<code>
/run local total = GetNumGuildMembers() or 0; local online = select(2, GetNumGuildMembers()) or 0; print("Всего:", total, "Онлайн:", online)
</code>
]=],
}

ns_llua['lua'][132] = {
type = "vartest",
title = "Тест 131-1: имя гильдии",
helpModules = {131, 65},
tasks = {
{
var = "guildName",
desc = 'Создай глобальную переменную guildName = GetGuildInfo("player") or "Без гильдии"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][133] = {
type = "vartest",
title = "Тест 131-2: количество участников гильдии",
helpModules = {131, 65},
tasks = {
{
var = "guildTotal",
desc = 'Создай глобальную переменную guildTotal = GetNumGuildMembers() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "guildOnline",
desc = 'Создай глобальную переменную guildOnline = select(2, GetNumGuildMembers()) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][134] = {
type = "commenttest",
title = "Тест 131-3: функция GetGuildNameSafe",
helpModules = {131, 45, 65},
preloadVars = {
{var = "GetGuildNameSafe", desc = "GetGuildNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 131-3: функция GetGuildNameSafe</h>
<t>Создай глобальную функцию <k>GetGuildNameSafe()</k>.</t>
<t>Функция должна вернуть имя гильдии игрока через:</t>
<code>
GetGuildInfo("player")
</code>
<t>Если имя не является непустой строкой, функция должна вернуть строку:</t>
<s>"Без гильдии"</s>
<t>Используй:</t>
<c>GetGuildInfo</c>
<c>type</c>
<c>return</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetGuildNameSafe()
]=],
requireKeywords = {
"GetGuildNameSafe",
"function",
"GetGuildInfo",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetGuildNameSafe) ~= "function" then
_G.checkError = "GetGuildNameSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetGuildNameSafe)
if not ok then
_G.checkError = "Ошибка вызова GetGuildNameSafe: " .. tostring(result)
return false
end
if type(result) ~= "string" or result == "" then
_G.checkError = "Функция должна вернуть непустую строку"
return false
end
return true
end,
}

ns_llua['lua'][135] = {
type = "commenttest",
title = "Тест 131-4: функция GetGuildMemberCountSafe",
helpModules = {131, 45, 65},
preloadVars = {
{var = "GetGuildMemberCountSafe", desc = "GetGuildMemberCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 131-4: функция GetGuildMemberCountSafe</h>
<t>Создай глобальную функцию <k>GetGuildMemberCountSafe()</k>.</t>
<t>Функция должна вернуть общее количество участников гильдии через:</t>
<code>
GetNumGuildMembers()
</code>
<t>Если значение не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetGuildMemberCountSafe()
]=],
requireKeywords = {
"GetGuildMemberCountSafe",
"function",
"GetNumGuildMembers",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetGuildMemberCountSafe) ~= "function" then
_G.checkError = "GetGuildMemberCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetGuildMemberCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetGuildMemberCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество участников гильдии не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][136] = {
type = "commenttest",
title = "Тест 131-5: функция GetGuildOnlineCountSafe",
helpModules = {131, 45, 65},
preloadVars = {
{var = "GetGuildOnlineCountSafe", desc = "GetGuildOnlineCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 131-5: функция GetGuildOnlineCountSafe</h>
<t>Создай глобальную функцию <k>GetGuildOnlineCountSafe()</k>.</t>
<t>Функция должна вернуть количество участников гильдии онлайн.</t>
<t>Используй:</t>
<code>
local total, online = GetNumGuildMembers()
</code>
<t>Если <k>online</k> не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetGuildOnlineCountSafe()
]=],
requireKeywords = {
"GetGuildOnlineCountSafe",
"function",
"GetNumGuildMembers",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetGuildOnlineCountSafe) ~= "function" then
_G.checkError = "GetGuildOnlineCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetGuildOnlineCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetGuildOnlineCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество участников онлайн не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][137] = {
type = "info",
title = "Координаты игрока",
helpModules = {65, 71, 14},
content = [=[
<h>Координаты игрока</h>
<t>Функция <k>GetPlayerMapPosition</k> возвращает координаты юнита на текущей карте.</t>
<code>
/run local x, y = GetPlayerMapPosition("player"); print(x, y)
</code>
<t>Координаты возвращаются как доли от 0 до 1.</t>
<t>Чтобы получить привычные проценты, их нужно умножить на 100.</t>
<code>
/run local x, y = GetPlayerMapPosition("player"); if x and y then print(string.format("X: %.1f, Y: %.1f", x * 100, y * 100)) end
</code>
<h>SetMapToCurrentZone</h>
<t>Иногда координаты могут быть <n>0, 0</n>, если текущая карта не соответствует зоне игрока.</t>
<code>
/run SetMapToCurrentZone(); local x, y = GetPlayerMapPosition("player"); if x and y then print(string.format("X: %.1f, Y: %.1f", x * 100, y * 100)) end
</code>
<w>Важно:</w> в некоторых местах, например в подземельях или на специальных картах, координаты могут быть недоступны.
<h>Безопасный шаблон</h>
<code>
/run local x, y = GetPlayerMapPosition("player"); x = x or 0; y = y or 0; print(string.format("X: %.1f, Y: %.1f", x * 100, y * 100))
</code>
<h>Формат вывода</h>
<t>В <k>string.format</k> метка <k>%.1f</k> означает число с одним знаком после запятой.</t>
<code>
print(string.format("%.1f", 12.345)) -- 12.3
print(string.format("%.2f", 12.345)) -- 12.35
</code>
]=],
}

ns_llua['lua'][138] = {
type = "vartest",
title = "Тест 137-1: сырые координаты игрока",
helpModules = {137, 65},
tasks = {
{
var = "mapX",
desc = 'Создай глобальную переменную mapX = (GetPlayerMapPosition("player")) or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 1
end,
},
{
var = "mapY",
desc = 'Создай глобальную переменную mapY = select(2, GetPlayerMapPosition("player")) or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 1
end,
},
},
}

ns_llua['lua'][139] = {
type = "vartest",
title = "Тест 137-2: координаты в процентах",
helpModules = {137, 10, 14},
tasks = {
{
var = "mapXPercent",
desc = 'Создай глобальную переменную mapXPercent = math.floor(((GetPlayerMapPosition("player")) or 0) * 100)',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 100
end,
},
{
var = "mapYPercent",
desc = 'Создай глобальную переменную mapYPercent = math.floor((select(2, GetPlayerMapPosition("player")) or 0) * 100)',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 100
end,
},
},
}

ns_llua['lua'][140] = {
type = "commenttest",
title = "Тест 137-3: функция GetPlayerCoordinatesRaw",
helpModules = {137, 45, 65},
preloadVars = {
{var = "GetPlayerCoordinatesRaw", desc = "GetPlayerCoordinatesRaw очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 137-3: функция GetPlayerCoordinatesRaw</h>
<t>Создай глобальную функцию <k>GetPlayerCoordinatesRaw()</k>.</t>
<t>Функция должна вернуть два значения:</t>
<c>1</c> — координату X игрока через <k>GetPlayerMapPosition("player")</k>.
<c>2</c> — координату Y игрока через <k>GetPlayerMapPosition("player")</k>.
<t>Если значение равно <k>nil</k>, используй <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetPlayerCoordinatesRaw()
]=],
requireKeywords = {
"GetPlayerCoordinatesRaw",
"function",
"GetPlayerMapPosition",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetPlayerCoordinatesRaw) ~= "function" then
_G.checkError = "GetPlayerCoordinatesRaw не является глобальной функцией"
return false
end
local ok, x, y = pcall(_G.GetPlayerCoordinatesRaw)
if not ok then
_G.checkError = "Ошибка вызова GetPlayerCoordinatesRaw: " .. tostring(x)
return false
end
if type(x) ~= "number" or type(y) ~= "number" then
_G.checkError = "Функция должна вернуть два числа"
return false
end
if x < 0 or x > 1 then
_G.checkError = "Координата X должна быть от 0 до 1"
return false
end
if y < 0 or y > 1 then
_G.checkError = "Координата Y должна быть от 0 до 1"
return false
end
return true
end,
}

ns_llua['lua'][141] = {
type = "commenttest",
title = "Тест 137-4: функция GetPlayerCoordinatesPercent",
helpModules = {137, 45, 10, 14},
preloadVars = {
{var = "GetPlayerCoordinatesPercent", desc = "GetPlayerCoordinatesPercent очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 137-4: функция GetPlayerCoordinatesPercent</h>
<t>Создай глобальную функцию <k>GetPlayerCoordinatesPercent()</k>.</t>
<t>Функция должна вернуть два значения:</t>
<c>1</c> — координату X игрока в процентах от 0 до 100.
<c>2</c> — координату Y игрока в процентах от 0 до 100.
<t>Используй:</t>
<c>GetPlayerMapPosition("player")</c>
<c>or 0</c>
<c>math.floor</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetPlayerCoordinatesPercent()
]=],
requireKeywords = {
"GetPlayerCoordinatesPercent",
"function",
"GetPlayerMapPosition",
"math.floor",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetPlayerCoordinatesPercent) ~= "function" then
_G.checkError = "GetPlayerCoordinatesPercent не является глобальной функцией"
return false
end
local ok, xPercent, yPercent = pcall(_G.GetPlayerCoordinatesPercent)
if not ok then
_G.checkError = "Ошибка вызова GetPlayerCoordinatesPercent: " .. tostring(xPercent)
return false
end
if type(xPercent) ~= "number" or type(yPercent) ~= "number" then
_G.checkError = "Функция должна вернуть два числа"
return false
end
if xPercent < 0 or xPercent > 100 then
_G.checkError = "Координата X в процентах должна быть от 0 до 100"
return false
end
if yPercent < 0 or yPercent > 100 then
_G.checkError = "Координата Y в процентах должна быть от 0 до 100"
return false
end
return true
end,
}

ns_llua['lua'][142] = {
type = "commenttest",
title = "Тест 137-5: функция GetCoordinateText",
helpModules = {137, 45, 14, 7},
preloadVars = {
{var = "GetCoordinateText", desc = "GetCoordinateText очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 137-5: функция GetCoordinateText</h>
<t>Создай глобальную функцию <k>GetCoordinateText()</k>.</t>
<t>Функция должна вернуть строку с координатами игрока в процентах.</t>
<t>Формат строки:</t>
<s>"X: 12.3, Y: 45.6"</s>
<t>Используй:</t>
<c>GetPlayerMapPosition("player")</c>
<c>or 0</c>
<c>string.format</c>
<c>%.1f</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetCoordinateText()
]=],
requireKeywords = {
"GetCoordinateText",
"function",
"GetPlayerMapPosition",
"string.format",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetCoordinateText) ~= "function" then
_G.checkError = "GetCoordinateText не является глобальной функцией"
return false
end
local ok, text = pcall(_G.GetCoordinateText)
if not ok then
_G.checkError = "Ошибка вызова GetCoordinateText: " .. tostring(text)
return false
end
if type(text) ~= "string" or text == "" then
_G.checkError = "Функция должна вернуть строку"
return false
end
if not text:find("X: ", 1, true) then
_G.checkError = "Строка должна начинаться с 'X: '"
return false
end
if not text:find(", Y: ", 1, true) then
_G.checkError = "Строка должна содержать ', Y: '"
return false
end
return true
end,
}

ns_llua['lua'][143] = {
type = "info",
title = "Направление и зоны",
helpModules = {137, 10, 14},
content = [=[
<h>Направление и зоны</h>
<t>Кроме координат, можно получить направление взгляда игрока и название зоны.</t>
<h>GetPlayerFacing</h>
<code>
/run print(GetPlayerFacing())
</code>
<t>Функция возвращает направление в радианах.</t>
<t>Чтобы перевести радианы в градусы, используй формулу:</t>
<code>
градусы = радианы * 180 / math.pi
</code>
<h>Пример перевода</h>
<code>
/run local facing = GetPlayerFacing() or 0; local degrees = math.floor(facing * 180 / math.pi + 0.5); print(degrees)
</code>
<t>Результат будет примерно от 0 до 360.</t>
<h>Названия зон</h>
<code>
/run print(GetZoneText())
/run print(GetRealZoneText())
/run print(GetMinimapZoneText())
/run print(GetSubZoneText())
</code>
<t>Разница:</t>
<c>GetZoneText</c> — основная зона.
<c>GetRealZoneText</c> — реальная зона, часто используется для континентов и крупных областей.
<c>GetMinimapZoneText</c> — текст миникарты.
<c>GetSubZoneText</c> — подзона, например конкретная улица, пещера или здание.
<h>Пример отчёта</h>
<code>
/run local zone = GetZoneText() or "Неизвестно"; local sub = GetSubZoneText() or ""; print(string.format("Зона: %s, подзона: %s", zone, sub))
</code>
<h>Безопасный шаблон</h>
<code>
/run local facing = GetPlayerFacing() or 0; if facing >= 0 then print("Направление доступно") else print("Направление недоступно") end
</code>
]=],
}

ns_llua['lua'][144] = {
type = "vartest",
title = "Тест 143-1: направление игрока",
helpModules = {143, 65, 10},
tasks = {
{
var = "playerFacing",
desc = 'Создай глобальную переменную playerFacing = GetPlayerFacing() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerFacingDegrees",
desc = 'Создай глобальную переменную playerFacingDegrees = math.floor((GetPlayerFacing() or 0) * 180 / math.pi + 0.5)',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 360
end,
},
},
}

ns_llua['lua'][145] = {
type = "vartest",
title = "Тест 143-2: зоны игрока",
helpModules = {143, 65},
tasks = {
{
var = "zoneText",
desc = 'Создай глобальную переменную zoneText = GetZoneText() or "Неизвестно"',
check = function(value)
return type(value) == "string"
end,
},
{
var = "minimapZoneText",
desc = 'Создай глобальную переменную minimapZoneText = GetMinimapZoneText() or ""',
check = function(value)
return type(value) == "string"
end,
},
},
}

ns_llua['lua'][146] = {
type = "commenttest",
title = "Тест 143-3: функция GetFacingDegrees",
helpModules = {143, 45, 10},
preloadVars = {
{var = "GetFacingDegrees", desc = "GetFacingDegrees очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 143-3: функция GetFacingDegrees</h>
<t>Создай глобальную функцию <k>GetFacingDegrees()</k>.</t>
<t>Функция должна вернуть направление игрока в градусах.</t>
<t>Используй:</t>
<c>GetPlayerFacing()</c>
<c>or 0</c>
<c>math.floor</c>
<c>math.pi</c>
<t>Если направление недоступно, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetFacingDegrees()
]=],
requireKeywords = {
"GetFacingDegrees",
"function",
"GetPlayerFacing",
"math.floor",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetFacingDegrees) ~= "function" then
_G.checkError = "GetFacingDegrees не является глобальной функцией"
return false
end
local ok, degrees = pcall(_G.GetFacingDegrees)
if not ok then
_G.checkError = "Ошибка вызова GetFacingDegrees: " .. tostring(degrees)
return false
end
if type(degrees) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if degrees < 0 or degrees > 360 then
_G.checkError = "Направление в градусах должно быть от 0 до 360"
return false
end
return true
end,
}

ns_llua['lua'][147] = {
type = "commenttest",
title = "Тест 143-4: функция GetZoneReport",
helpModules = {143, 45, 7},
preloadVars = {
{var = "GetZoneReport", desc = "GetZoneReport очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 143-4: функция GetZoneReport</h>
<t>Создай глобальную функцию <k>GetZoneReport()</k>.</t>
<t>Функция должна вернуть строку:</t>
<s>"Зона: название"</s>
<t>Если <k>GetZoneText()</k> вернул <k>nil</k>, используй строку:</t>
<s>"Неизвестно"</s>
<t>Используй:</t>
<c>GetZoneText</c>
<c>or</c>
<c>конкатенацию</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetZoneReport()
]=],
requireKeywords = {
"GetZoneReport",
"function",
"GetZoneText",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetZoneReport) ~= "function" then
_G.checkError = "GetZoneReport не является глобальной функцией"
return false
end
local ok, text = pcall(_G.GetZoneReport)
if not ok then
_G.checkError = "Ошибка вызова GetZoneReport: " .. tostring(text)
return false
end
if type(text) ~= "string" or text == "" then
_G.checkError = "Функция должна вернуть строку"
return false
end
if not text:find("Зона: ", 1, true) then
_G.checkError = "Строка должна начинаться с 'Зона: '"
return false
end
return true
end,
}

ns_llua['lua'][148] = {
type = "commenttest",
title = "Тест 143-5: функция GetCardinalDirection",
helpModules = {143, 45, 17, 19},
preloadVars = {
{var = "GetCardinalDirection", desc = "GetCardinalDirection очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 143-5: функция GetCardinalDirection</h>
<t>Создай глобальную функцию <k>GetCardinalDirection(degrees)</k>.</t>
<t>Функция должна вернуть сторону света по градусам.</t>
<t>Правила:</t>
<c>0-44</c> — <s>"Север"</s>
<c>45-134</c> — <s>"Восток"</s>
<c>135-224</c> — <s>"Юг"</s>
<c>225-314</c> — <s>"Запад"</s>
<c>315-359</c> — <s>"Север"</s>
<t>Если <k>degrees</k> не число, меньше 0 или больше либо равно 360, функция должна вернуть:</t>
<s>"Неизвестно"</s>
<t>Используй:</t>
<c>type</c>
<c>if</c>
<c>elseif</c>
<c>else</c>
<c>return</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetCardinalDirection(degrees)
]=],
requireKeywords = {
"GetCardinalDirection",
"function",
"type",
"if",
"then",
"elseif",
"else",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetCardinalDirection) ~= "function" then
_G.checkError = "GetCardinalDirection не является глобальной функцией"
return false
end
local tests = {
{input = 0, expected = "Север"},
{input = 44, expected = "Север"},
{input = 45, expected = "Восток"},
{input = 90, expected = "Восток"},
{input = 134, expected = "Восток"},
{input = 135, expected = "Юг"},
{input = 180, expected = "Юг"},
{input = 224, expected = "Юг"},
{input = 225, expected = "Запад"},
{input = 270, expected = "Запад"},
{input = 314, expected = "Запад"},
{input = 315, expected = "Север"},
{input = 359, expected = "Север"},
{input = -1, expected = "Неизвестно"},
{input = 360, expected = "Неизвестно"},
{input = "bad", expected = "Неизвестно"},
}
for i, test in ipairs(tests) do
local ok, result = pcall(_G.GetCardinalDirection, test.input)
if not ok or result ~= test.expected then
_G.checkError = "Тест " .. i .. " функции GetCardinalDirection не пройден"
return false
end
end
return true
end,
}

ns_llua['lua'][149] = {
type = "info",
title = "Скорость и перемещение",
helpModules = {143, 65},
content = [=[
<h>Скорость и перемещение</h>
<t>WoW API позволяет получить скорость игрока и проверить, находится ли он верхом, летит или плывёт.</t>
<h>GetPlayerSpeed</h>
<code>
/run local runSpeed, flightSpeed = GetPlayerSpeed(); print(runSpeed, flightSpeed)
</code>
<t>Функция возвращает скорость бега и скорость полёта.</t>
<w>Примечание:</w> значения могут отличаться в зависимости от версии клиента и настроек. Их удобно смотреть через <k>/dump</k>.
<code>
/dump GetPlayerSpeed()
</code>
<h>GetUnitSpeed</h>
<t>Если функция доступна, можно получить скорость конкретного юнита.</t>
<code>
/run print(GetUnitSpeed("player"))
</code>
<h>Состояния движения</h>
<code>
/run print(IsMounted())
/run print(IsFlying())
/run print(IsSwimming())
/run print(IsIndoors())
/run print(IsOutdoors())
</code>
<t>Как и многие функции WoW 3.3.5, они могут возвращать <k>1</k> или <k>nil</k>.</t>
<h>Пример условия</h>
<code>
/run if IsMounted() then print("Верхом") else print("Пешком") end
</code>
<h>Приведение к boolean</h>
<code>
/run local mounted = not not IsMounted(); print(mounted, type(mounted))
</code>
<h>Мини-отчёт</h>
<code>
/run local state = "Пешком"; if IsFlying() then state = "Летит" elseif IsMounted() then state = "Верхом" elseif IsSwimming() then state = "Плывёт" end; print(state)
</code>
<h>Безопасный шаблон скорости</h>
<code>
/run local speed = 0; if GetPlayerSpeed then speed = GetPlayerSpeed() or 0 end; print("Скорость:", speed)
</code>
]=],
}

ns_llua['lua'][150] = {
type = "vartest",
title = "Тест 149-1: состояния движения",
helpModules = {149, 15},
tasks = {
{
var = "isMounted",
desc = 'Создай глобальную переменную isMounted = not not IsMounted()',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "isFlying",
desc = 'Создай глобальную переменную isFlying = not not IsFlying()',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "isSwimming",
desc = 'Создай глобальную переменную isSwimming = not not IsSwimming()',
check = function(value)
return type(value) == "boolean"
end,
},
},
}

ns_llua['lua'][151] = {
type = "vartest",
title = "Тест 149-2: скорость игрока",
helpModules = {149, 65},
tasks = {
{
var = "runSpeed",
desc = 'Создай глобальную переменную runSpeed: если GetPlayerSpeed существует, используй её результат, иначе 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "flightSpeed",
desc = 'Создай глобальную переменную flightSpeed: если GetPlayerSpeed существует, используй второй результат через select(2, ...), иначе 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][152] = {
type = "commenttest",
title = "Тест 149-3: функция GetMovementState",
helpModules = {149, 45, 17, 19},
preloadVars = {
{var = "GetMovementState", desc = "GetMovementState очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 149-3: функция GetMovementState</h>
<t>Создай глобальную функцию <k>GetMovementState()</k>.</t>
<t>Функция должна вернуть одно из значений:</t>
<c>"flying"</c> — если <k>IsFlying()</k> истинно.
<c>"mounted"</c> — если игрок не летит, но <k>IsMounted()</k> истинно.
<c>"swimming"</c> — если игрок не летит, не верхом, но <k>IsSwimming()</k> истинно.
<c>"normal"</c> — во всех остальных случаях.
<t>Используй:</t>
<c>IsFlying</c>
<c>IsMounted</c>
<c>IsSwimming</c>
<c>if / elseif / else</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetMovementState()
]=],
requireKeywords = {
"GetMovementState",
"function",
"IsFlying",
"IsMounted",
"IsSwimming",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetMovementState) ~= "function" then
_G.checkError = "GetMovementState не является глобальной функцией"
return false
end
local ok, state = pcall(_G.GetMovementState)
if not ok then
_G.checkError = "Ошибка вызова GetMovementState: " .. tostring(state)
return false
end
local valid = {
flying = true,
mounted = true,
swimming = true,
normal = true,
}
if type(state) ~= "string" or not valid[state] then
_G.checkError = "Функция должна вернуть flying, mounted, swimming или normal"
return false
end
return true
end,
}

ns_llua['lua'][153] = {
type = "commenttest",
title = "Тест 149-4: функция GetSpeedReport",
helpModules = {149, 45, 7, 65},
preloadVars = {
{var = "GetSpeedReport", desc = "GetSpeedReport очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 149-4: функция GetSpeedReport</h>
<t>Создай глобальную функцию <k>GetSpeedReport()</k>.</t>
<t>Функция должна вернуть строку:</t>
<s>"Скорость: значение"</s>
<t>Если функция <k>GetPlayerSpeed</k> недоступна, используй значение <n>0</n>.</t>
<t>Используй:</t>
<c>GetPlayerSpeed</c>
<c>tostring</c>
<c>конкатенацию</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSpeedReport()
]=],
requireKeywords = {
"GetSpeedReport",
"function",
"GetPlayerSpeed",
"tostring",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSpeedReport) ~= "function" then
_G.checkError = "GetSpeedReport не является глобальной функцией"
return false
end
local ok, text = pcall(_G.GetSpeedReport)
if not ok then
_G.checkError = "Ошибка вызова GetSpeedReport: " .. tostring(text)
return false
end
if type(text) ~= "string" or text == "" then
_G.checkError = "Функция должна вернуть строку"
return false
end
if not text:find("Скорость: ", 1, true) then
_G.checkError = "Строка должна начинаться с 'Скорость: '"
return false
end
return true
end,
}

ns_llua['lua'][154] = {
type = "commenttest",
title = "Тест 149-5: функция IsMountedOrFlying",
helpModules = {149, 45, 21},
preloadVars = {
{var = "IsMountedOrFlying", desc = "IsMountedOrFlying очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 149-5: функция IsMountedOrFlying</h>
<t>Создай глобальную функцию <k>IsMountedOrFlying()</k>.</t>
<t>Функция должна вернуть <k>true</k>, если игрок верхом или летит.</t>
<t>Иначе функция должна вернуть <k>false</k>.</t>
<t>Используй:</t>
<c>IsMounted()</c>
<c>IsFlying()</c>
<c>or</c>
<c>and true or false</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию IsMountedOrFlying()
]=],
requireKeywords = {
"IsMountedOrFlying",
"function",
"IsMounted",
"IsFlying",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.IsMountedOrFlying) ~= "function" then
_G.checkError = "IsMountedOrFlying не является глобальной функцией"
return false
end
local ok, result = pcall(_G.IsMountedOrFlying)
if not ok then
_G.checkError = "Ошибка вызова IsMountedOrFlying: " .. tostring(result)
return false
end
if type(result) ~= "boolean" then
_G.checkError = "Функция должна вернуть boolean"
return false
end
return true
end,
}

ns_llua['lua'][155] = {
type = "info",
title = "Время, FPS и пинг",
helpModules = {65, 10, 14},
content = [=[
<h>Время, FPS и пинг</h>
<t>Эти функции полезны для таймеров, измерений и диагностики.</t>
<h>GetTime</h>
<code>
/run print(GetTime())
</code>
<t>Возвращает время в секундах. Обычно это время с момента загрузки интерфейса.</t>
<h>Целые секунды</h>
<code>
/run print(math.floor(GetTime()))
</code>
<h>Минуты и секунды</h>
<code>
/run local t = math.floor(GetTime()); print(string.format("Прошло %d мин %d сек", math.floor(t / 60), t % 60))
</code>
<h>GetGameTime</h>
<code>
/run local hour, minute = GetGameTime(); print(hour, minute)
</code>
<t>Функция возвращает игровое или серверное время в формате часы и минуты.</t>
<h>GetFramerate</h>
<code>
/run print(math.floor(GetFramerate()))
</code>
<t>Возвращает текущий FPS.</t>
<h>GetNetStats</h>
<t>Функция возвращает статистику сети. Удобнее всего сначала посмотреть её через <k>/dump</k>.</t>
<code>
/dump GetNetStats()
</code>
<t>Пример получения домашнего пинга:</t>
<code>
/run local _, _, latencyHome = GetNetStats(); print(latencyHome or 0)
</code>
<w>Примечание:</w> порядок возвращаемых значений может зависеть от версии клиента, поэтому при сомнениях используй <k>/dump</k>.
<h>Безопасный шаблон</h>
<code>
/run local fps = GetFramerate() or 0; print(string.format("FPS: %d", math.floor(fps)))
</code>
]=],
}

ns_llua['lua'][156] = {
type = "vartest",
title = "Тест 155-1: время сессии",
helpModules = {155, 65, 10},
tasks = {
{
var = "gameTimeSeconds",
desc = 'Создай глобальную переменную gameTimeSeconds = GetTime() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "gameTimeMinutes",
desc = 'Создай глобальную переменную gameTimeMinutes = math.floor((GetTime() or 0) / 60)',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][157] = {
type = "vartest",
title = "Тест 155-2: игровое время",
helpModules = {155, 65},
tasks = {
{
var = "gameHour",
desc = 'Создай глобальную переменную gameHour = GetGameTime() or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 23
end,
},
{
var = "gameMinute",
desc = 'Создай глобальную переменную gameMinute = select(2, GetGameTime()) or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 59
end,
},
},
}

ns_llua['lua'][158] = {
type = "commenttest",
title = "Тест 155-3: функция GetSessionTimeText",
helpModules = {155, 45, 14, 10},
preloadVars = {
{var = "GetSessionTimeText", desc = "GetSessionTimeText очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 155-3: функция GetSessionTimeText</h>
<t>Создай глобальную функцию <k>GetSessionTimeText()</k>.</t>
<t>Функция должна вернуть строку с временем сессии.</t>
<t>Формат строки:</t>
<s>"Минут: X, Секунд: Y"</s>
<t>Используй:</t>
<c>GetTime()</c>
<c>math.floor</c>
<c>остаток от деления %</c>
<c>string.format</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSessionTimeText()
]=],
requireKeywords = {
"GetSessionTimeText",
"function",
"GetTime",
"math.floor",
"string.format",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSessionTimeText) ~= "function" then
_G.checkError = "GetSessionTimeText не является глобальной функцией"
return false
end
local ok, text = pcall(_G.GetSessionTimeText)
if not ok then
_G.checkError = "Ошибка вызова GetSessionTimeText: " .. tostring(text)
return false
end
if type(text) ~= "string" or text == "" then
_G.checkError = "Функция должна вернуть строку"
return false
end
if not text:find("Минут: ", 1, true) then
_G.checkError = "Строка должна содержать 'Минут: '"
return false
end
if not text:find(", Секунд: ", 1, true) then
_G.checkError = "Строка должна содержать ', Секунд: '"
return false
end
return true
end,
}

ns_llua['lua'][159] = {
type = "commenttest",
title = "Тест 155-4: функция GetFramerateSafe",
helpModules = {155, 45, 65},
preloadVars = {
{var = "GetFramerateSafe", desc = "GetFramerateSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 155-4: функция GetFramerateSafe</h>
<t>Создай глобальную функцию <k>GetFramerateSafe()</k>.</t>
<t>Функция должна вернуть FPS как число.</t>
<t>Используй:</t>
<c>GetFramerate()</c>
<c>or 0</c>
<t>Если FPS получить нельзя, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetFramerateSafe()
]=],
requireKeywords = {
"GetFramerateSafe",
"function",
"GetFramerate",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetFramerateSafe) ~= "function" then
_G.checkError = "GetFramerateSafe не является глобальной функцией"
return false
end
local ok, fps = pcall(_G.GetFramerateSafe)
if not ok then
_G.checkError = "Ошибка вызова GetFramerateSafe: " .. tostring(fps)
return false
end
if type(fps) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if fps < 0 then
_G.checkError = "FPS не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][160] = {
type = "commenttest",
title = "Тест 155-5: функция GetLatencySafe",
helpModules = {155, 45, 65},
preloadVars = {
{var = "GetLatencySafe", desc = "GetLatencySafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 155-5: функция GetLatencySafe</h>
<t>Создай глобальную функцию <k>GetLatencySafe()</k>.</t>
<t>Функция должна вернуть пинг как число.</t>
<t>Используй:</t>
<c>GetNetStats()</c>
<c>select(3, ...)</c>
<c>or 0</c>
<t>Если пинг получить нельзя, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetLatencySafe()
]=],
requireKeywords = {
"GetLatencySafe",
"function",
"GetNetStats",
"select",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetLatencySafe) ~= "function" then
_G.checkError = "GetLatencySafe не является глобальной функцией"
return false
end
local ok, latency = pcall(_G.GetLatencySafe)
if not ok then
_G.checkError = "Ошибка вызова GetLatencySafe: " .. tostring(latency)
return false
end
if type(latency) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if latency < 0 then
_G.checkError = "Пинг не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][161] = {
type = "info",
title = "Деньги и опыт",
helpModules = {65, 10, 14},
content = [=[
<h>Деньги и опыт</h>
<t>Деньги в WoW хранятся в меди. 100 меди — 1 серебро. 100 серебра — 1 золото.</t>
<h>GetMoney</h>
<code>
/run print(GetMoney())
</code>
<t>Функция возвращает общее количество меди.</t>
<h>Ручное форматирование</h>
<code>
/run local copper = GetMoney() or 0; local gold = math.floor(copper / 10000); local silver = math.floor((copper % 10000) / 100); local cop = copper % 100; print(string.format("%dз %dс %dм", gold, silver, cop))
</code>
<t>Здесь:</t>
<c>copper / 10000</c> — золото.
<c>(copper % 10000) / 100</c> — серебро.
<c>copper % 100</c> — медь.
<h>GetCoinTextureString</h>
<t>Готовая функция для красивого вывода денег.</t>
<code>
/run print(GetCoinTextureString(GetMoney()))
</code>
<h>Опыт</h>
<code>
/run local xp = UnitXP("player"); local xpMax = UnitXPMax("player"); print(xp, xpMax)
</code>
<h>Процент опыта</h>
<code>
/run local xp = UnitXP("player") or 0; local xpMax = UnitXPMax("player") or 0; if xpMax > 0 then print(string.format("XP: %d%%", math.floor(xp / xpMax * 100))) else print("XP: 0%") end
</code>
<w>Важно:</w> на максимальном уровне <k>xpMax</k> может быть <n>0</n>, поэтому деление нужно проверять.
<h>Отдых</h>
<code>
/run print(GetXPExhaustion())
</code>
<t>Функция возвращает количество накопленного отдыха, если оно доступно.</t>
]=],
}

ns_llua['lua'][162] = {
type = "vartest",
title = "Тест 161-1: деньги игрока",
helpModules = {161, 65, 10},
tasks = {
{
var = "playerMoney",
desc = 'Создай глобальную переменную playerMoney = GetMoney() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerGold",
desc = 'Создай глобальную переменную playerGold = math.floor((GetMoney() or 0) / 10000)',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][163] = {
type = "vartest",
title = "Тест 161-2: опыт игрока",
helpModules = {161, 65},
tasks = {
{
var = "playerXP",
desc = 'Создай глобальную переменную playerXP = UnitXP("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerXPMax",
desc = 'Создай глобальную переменную playerXPMax = UnitXPMax("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][164] = {
type = "commenttest",
title = "Тест: функция GetMoneyParts",
helpModules = {161, 45, 10},
preloadVars = {
{var = "GetMoneyParts", desc = "GetMoneyParts очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 161-3: функция GetMoneyParts</h>
<t>Создай глобальную функцию <k>GetMoneyParts()</k>.</t>
<t>Функция должна вернуть три значения:</t>
<c>1</c> — золото.
<c>2</c> — серебро.
<c>3</c> — медь.
<t>Используй:</t>
<c>GetMoney()</c>
<c>or 0</c>
<c>math.floor</c>
<c>остаток от деления %</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetMoneyParts()
]=],
requireKeywords = {
"GetMoneyParts",
"function",
"GetMoney",
"math.floor",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetMoneyParts) ~= "function" then
_G.checkError = "GetMoneyParts не является глобальной функцией"
return false
end
local money = GetMoney() or 0
local expectedGold = math.floor(money / 10000)
local expectedSilver = math.floor((money % 10000) / 100)
local expectedCopper = money % 100
local ok, gold, silver, copper = pcall(_G.GetMoneyParts)
if not ok then
_G.checkError = "Ошибка вызова GetMoneyParts: " .. tostring(gold)
return false
end
if type(gold) ~= "number" or type(silver) ~= "number" or type(copper) ~= "number" then
_G.checkError = "Функция должна вернуть три числа"
return false
end
if gold ~= expectedGold or silver ~= expectedSilver or copper ~= expectedCopper then
_G.checkError = "Золото, серебро или медь посчитаны неверно"
return false
end
return true
end,
}

ns_llua['lua'][165] = {
type = "commenttest",
title = "Тест 161-4: функция GetMoneyText",
helpModules = {161, 45, 14, 10},
preloadVars = {
{var = "GetMoneyText", desc = "GetMoneyText очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 161-4: функция GetMoneyText</h>
<t>Создай глобальную функцию <k>GetMoneyText()</k>.</t>
<t>Функция должна вернуть строку с деньгами игрока.</t>
<t>Формат строки:</t>
<s>"12з 34с 56м"</s>
<t>Используй:</t>
<c>GetMoney()</c>
<c>or 0</c>
<c>math.floor</c>
<c>остаток от деления %</c>
<c>string.format</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetMoneyText()
]=],
requireKeywords = {
"GetMoneyText",
"function",
"GetMoney",
"math.floor",
"string.format",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetMoneyText) ~= "function" then
_G.checkError = "GetMoneyText не является глобальной функцией"
return false
end
local ok, text = pcall(_G.GetMoneyText)
if not ok then
_G.checkError = "Ошибка вызова GetMoneyText: " .. tostring(text)
return false
end
if type(text) ~= "string" or text == "" then
_G.checkError = "Функция должна вернуть строку"
return false
end
if not text:match("^%d+з %d+с %d+м$") then
_G.checkError = "Строка должна иметь формат 'золото з серебро с медь м'"
return false
end
return true
end,
}

ns_llua['lua'][166] = {
type = "commenttest",
title = "Тест 161-5: функция GetXPPercent",
helpModules = {161, 45, 10, 65},
preloadVars = {
{var = "GetXPPercent", desc = "GetXPPercent очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 161-5: функция GetXPPercent</h>
<t>Создай глобальную функцию <k>GetXPPercent()</k>.</t>
<t>Функция должна вернуть процент опыта игрока от 0 до 100.</t>
<t>Используй:</t>
<c>UnitXP("player")</c>
<c>UnitXPMax("player")</c>
<c>or 0</c>
<c>math.floor</c>
<t>Если максимальный опыт меньше или равен нулю, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetXPPercent()
]=],
requireKeywords = {
"GetXPPercent",
"function",
"UnitXP",
"UnitXPMax",
"math.floor",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetXPPercent) ~= "function" then
_G.checkError = "GetXPPercent не является глобальной функцией"
return false
end
local ok, percent = pcall(_G.GetXPPercent)
if not ok then
_G.checkError = "Ошибка вызова GetXPPercent: " .. tostring(percent)
return false
end
if type(percent) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if percent < 0 or percent > 100 then
_G.checkError = "Процент опыта должен быть от 0 до 100"
return false
end
local xp = UnitXP("player") or 0
local xpMax = UnitXPMax("player") or 0
local expected = 0
if xpMax > 0 then
expected = math.floor(xp / xpMax * 100)
end
if math.abs(percent - expected) > 2 then
_G.checkError = "Процент опыта не совпадает с текущим опытом игрока"
return false
end
return true
end,
}

ns_llua['lua'][167] = {
type = "info",
title = "Сумки: ячейки и свободное место",
helpModules = {65, 31, 45},
content = [=[
<h>Сумки: ячейки и свободное место</h>
<t>В WoW 3.3.5 основные сумки имеют ID от 0 до 4.</t>
<c>0</c> — рюкзак.
<c>1</c> — первая дополнительная сумка.
<c>2</c> — вторая дополнительная сумка.
<c>3</c> — третья дополнительная сумка.
<c>4</c> — четвёртая дополнительная сумка.
<h>Количество ячеек</h>
<code>
/run print(GetContainerNumSlots(0))
</code>
<h>Свободные ячейки</h>
<code>
/run print(GetContainerNumFreeSlots(0))
</code>
<t>Функция может вернуть несколько значений. Первое — количество свободных ячеек.</t>
<h>Цикл по сумкам</h>
<code>
/run local total = 0; for bag = 0, 4 do total = total + (GetContainerNumSlots(bag) or 0) end; print("Всего ячеек:", total)
</code>
<h>Свободное место</h>
<code>
/run local free = 0; for bag = 0, 4 do free = free + (GetContainerNumFreeSlots(bag) or 0) end; print("Свободно:", free)
</code>
<w>Важно:</w> конструкция <k>(GetContainerNumFreeSlots(bag) or 0)</k> нужна, чтобы заменить возможный <k>nil</k> на ноль.
<h>Таблица отчёта</h>
<code>
/run bagReport = {}; for bag = 0, 4 do bagReport[bag] = { slots = GetContainerNumSlots(bag) or 0, free = GetContainerNumFreeSlots(bag) or 0 } end; print(bagReport[0].slots, bagReport[0].free)
</code>
]=],
}

ns_llua['lua'][168] = {
type = "vartest",
title = "Тест 167-1: рюкзак игрока",
helpModules = {167, 65},
tasks = {
{
var = "bagSlots0",
desc = 'Создай глобальную переменную bagSlots0 = GetContainerNumSlots(0) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "bagFree0",
desc = 'Создай глобальную переменную bagFree0 = GetContainerNumFreeSlots(0) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][169] = {
type = "vartest",
title = "Тест 167-2: таблица ID сумок",
helpModules = {167, 44},
tasks = {
{
var = "bagIDs",
desc = 'Создай глобальную таблицу bagIDs = {0, 1, 2, 3, 4}',
check = function(value)
return type(value) == "table"
and #value == 5
and value[1] == 0
and value[2] == 1
and value[3] == 2
and value[4] == 3
and value[5] == 4
end,
},
},
}

ns_llua['lua'][170] = {
type = "commenttest",
title = "Тест 167-3: функция GetBagSlotCount",
helpModules = {167, 45, 65},
preloadVars = {
{var = "GetBagSlotCount", desc = "GetBagSlotCount очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 167-3: функция GetBagSlotCount</h>
<t>Создай глобальную функцию <k>GetBagSlotCount(bag)</k>.</t>
<t>Если <k>bag</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество ячеек в сумке через:</t>
<code>
GetContainerNumSlots(bag)
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetBagSlotCount(bag)
]=],
requireKeywords = {
"GetBagSlotCount",
"function",
"GetContainerNumSlots",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetBagSlotCount) ~= "function" then
_G.checkError = "GetBagSlotCount не является глобальной функцией"
return false
end
local ok1, backpack = pcall(_G.GetBagSlotCount, 0)
if not ok1 then
_G.checkError = "Ошибка вызова GetBagSlotCount(0): " .. tostring(backpack)
return false
end
if type(backpack) ~= "number" or backpack < 0 then
_G.checkError = "Для сумки 0 функция должна вернуть число больше или равное нулю"
return false
end
local ok2, invalidBag = pcall(_G.GetBagSlotCount, -1)
if not ok2 or invalidBag ~= 0 then
_G.checkError = "Для сумки -1 функция должна вернуть 0"
return false
end
local ok3, badBag = pcall(_G.GetBagSlotCount, "bad")
if not ok3 or badBag ~= 0 then
_G.checkError = "Для нечислового аргумента функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][171] = {
type = "commenttest",
title = "Тест 167-4: функция GetTotalBagSlots",
helpModules = {167, 45, 31, 65},
preloadVars = {
{var = "GetTotalBagSlots", desc = "GetTotalBagSlots очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 167-4: функция GetTotalBagSlots</h>
<t>Создай глобальную функцию <k>GetTotalBagSlots()</k>.</t>
<t>Функция должна вернуть общее количество ячеек во всех сумках от 0 до 4.</t>
<t>Используй цикл и:</t>
<code>
GetContainerNumSlots(bag)
</code>
<t>Если функция вернула <k>nil</k>, используй <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetTotalBagSlots()
]=],
requireKeywords = {
"GetTotalBagSlots",
"function",
"for",
"GetContainerNumSlots",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetTotalBagSlots) ~= "function" then
_G.checkError = "GetTotalBagSlots не является глобальной функцией"
return false
end
local expected = 0
for bag = 0, 4 do
local slots = GetContainerNumSlots(bag)
if type(slots) == "number" and slots > 0 then
expected = expected + slots
end
end
local ok, total = pcall(_G.GetTotalBagSlots)
if not ok then
_G.checkError = "Ошибка вызова GetTotalBagSlots: " .. tostring(total)
return false
end
if type(total) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if total ~= expected then
_G.checkError = "Общее количество ячеек не совпадает с суммой по сумкам 0-4"
return false
end
return true
end,
}

ns_llua['lua'][172] = {
type = "commenttest",
title = "Тест 167-5: функция GetTotalFreeBagSlots",
helpModules = {167, 45, 31, 65},
preloadVars = {
{var = "GetTotalFreeBagSlots", desc = "GetTotalFreeBagSlots очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 167-5: функция GetTotalFreeBagSlots</h>
<t>Создай глобальную функцию <k>GetTotalFreeBagSlots()</k>.</t>
<t>Функция должна вернуть общее количество свободных ячеек во всех сумках от 0 до 4.</t>
<t>Используй цикл и:</t>
<code>
GetContainerNumFreeSlots(bag)
</code>
<t>Если функция вернула <k>nil</k>, используй <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetTotalFreeBagSlots()
]=],
requireKeywords = {
"GetTotalFreeBagSlots",
"function",
"for",
"GetContainerNumFreeSlots",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetTotalFreeBagSlots) ~= "function" then
_G.checkError = "GetTotalFreeBagSlots не является глобальной функцией"
return false
end
local expected = 0
for bag = 0, 4 do
local freeSlots = GetContainerNumFreeSlots(bag)
if type(freeSlots) == "number" and freeSlots > 0 then
expected = expected + freeSlots
end
end
local ok, freeTotal = pcall(_G.GetTotalFreeBagSlots)
if not ok then
_G.checkError = "Ошибка вызова GetTotalFreeBagSlots: " .. tostring(freeTotal)
return false
end
if type(freeTotal) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if freeTotal ~= expected then
_G.checkError = "Количество свободных ячеек не совпадает с суммой по сумкам 0-4"
return false
end
return true
end,
}

ns_llua['lua'][173] = {
type = "info",
title = "Предметы в сумках",
helpModules = {167, 65},
content = [=[
<h>Предметы в сумках</h>
<t>Чтобы получить предмет в сумке, нужны два аргумента: ID сумки и номер ячейки.</t>
<h>GetContainerItemLink</h>
<code>
/run local link = GetContainerItemLink(0, 1); print(link or "Пусто")
</code>
<t>Если ячейка пустая, функция вернёт <k>nil</k>.</t>
<t>Если предмет есть, функция вернёт строку-ссылку предмета. Такая ссылка содержит цвет, имя и внутреннюю информацию о предмете.</t>
<h>GetContainerItemInfo</h>
<code>
/run local texture, count = GetContainerItemInfo(0, 1); print(texture, count)
</code>
<t>Функция возвращает несколько значений. Основные:</t>
<c>texture</c> — иконка предмета.
<c>count</c> — количество предметов в ячейке.
<c>locked</c> — заблокирован ли предмет.
<c>quality</c> — качество предмета.
<h>GetContainerItemID</h>
<code>
/run print(GetContainerItemID(0, 1))
</code>
<t>Возвращает числовой ID предмета, если ячейка не пустая.</t>
<h>Перебор первой сумки</h>
<code>
/run local slots = GetContainerNumSlots(0) or 0; for slot = 1, slots do local link = GetContainerItemLink(0, slot); if link then print(slot, link) end end
</code>
<h>Подсчёт занятых ячеек</h>
<code>
/run local slots = GetContainerNumSlots(0) or 0; local used = 0; for slot = 1, slots do if GetContainerItemLink(0, slot) then used = used + 1 end end; print("Занято:", used)
</code>
<w>Примечание:</w> ссылка на предмет может содержать цветовые коды и специальные символы. Это нормально: именно такие ссылки WoW использует для показа предметов в чате.
]=],
}

ns_llua['lua'][174] = {
type = "vartest",
title = "Тест 173-1: первый слот рюкзака",
helpModules = {173, 167, 65},
tasks = {
{
var = "backpackSlots",
desc = 'Создай глобальную переменную backpackSlots = GetContainerNumSlots(0) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "backpackFirstLink",
desc = 'Создай глобальную переменную backpackFirstLink = GetContainerItemLink(0, 1) or "empty"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][175] = {
type = "vartest",
title = "Тест 173-2: ID и количество предмета",
helpModules = {173, 167, 65},
tasks = {
{
var = "backpackFirstID",
desc = 'Создай глобальную переменную backpackFirstID = GetContainerItemID(0, 1) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "backpackFirstCount",
desc = 'Создай глобальную переменную backpackFirstCount = select(2, GetContainerItemInfo(0, 1)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][176] = {
type = "commenttest",
title = "Тест 173-3: функция GetContainerItemLinkSafe",
helpModules = {173, 45, 65},
preloadVars = {
{var = "GetContainerItemLinkSafe", desc = "GetContainerItemLinkSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 173-3: функция GetContainerItemLinkSafe</h>
<t>Создай глобальную функцию <k>GetContainerItemLinkSafe(bag, slot)</k>.</t>
<t>Если <k>bag</k> или <k>slot</k> не являются числами, функция должна вернуть строку:</t>
<s>"empty"</s>
<t>Иначе функция должна получить ссылку на предмет через:</t>
<code>
GetContainerItemLink(bag, slot)
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"empty"</s>
<t>Иначе функция должна вернуть саму ссылку на предмет.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetContainerItemLinkSafe(bag, slot)
]=],
requireKeywords = {
"GetContainerItemLinkSafe",
"function",
"GetContainerItemLink",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetContainerItemLinkSafe) ~= "function" then
_G.checkError = "GetContainerItemLinkSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetContainerItemLinkSafe, 0, 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetContainerItemLinkSafe(0, 1): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для bag = 0 и slot = 1 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetContainerItemLinkSafe, "bad", 1)
if not ok2 or result2 ~= "empty" then
_G.checkError = "Для нечислового bag функция должна вернуть 'empty'"
return false
end
local ok3, result3 = pcall(_G.GetContainerItemLinkSafe, 0, "bad")
if not ok3 or result3 ~= "empty" then
_G.checkError = "Для нечислового slot функция должна вернуть 'empty'"
return false
end
return true
end,
}

ns_llua['lua'][177] = {
type = "commenttest",
title = "Тест 173-4: функция GetContainerItemCountSafe",
helpModules = {173, 45, 65},
preloadVars = {
{var = "GetContainerItemCountSafe", desc = "GetContainerItemCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 173-4: функция GetContainerItemCountSafe</h>
<t>Создай глобальную функцию <k>GetContainerItemCountSafe(bag, slot)</k>.</t>
<t>Если <k>bag</k> или <k>slot</k> не являются числами, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить количество предметов через:</t>
<code>
select(2, GetContainerItemInfo(bag, slot))
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть само количество.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetContainerItemCountSafe(bag, slot)
]=],
requireKeywords = {
"GetContainerItemCountSafe",
"function",
"GetContainerItemInfo",
"select",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetContainerItemCountSafe) ~= "function" then
_G.checkError = "GetContainerItemCountSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetContainerItemCountSafe, 0, 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetContainerItemCountSafe(0, 1): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 then
_G.checkError = "Для bag = 0 и slot = 1 функция должна вернуть число больше или равное нулю"
return false
end
local ok2, result2 = pcall(_G.GetContainerItemCountSafe, "bad", 1)
if not ok2 or result2 ~= 0 then
_G.checkError = "Для нечислового bag функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.GetContainerItemCountSafe, 0, "bad")
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нечислового slot функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][178] = {
type = "commenttest",
title = "Тест 173-5: функция CountFilledSlotsInBag",
helpModules = {173, 45, 31, 65},
preloadVars = {
{var = "CountFilledSlotsInBag", desc = "CountFilledSlotsInBag очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 173-5: функция CountFilledSlotsInBag</h>
<t>Создай глобальную функцию <k>CountFilledSlotsInBag(bag)</k>.</t>
<t>Если <k>bag</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить количество ячеек через:</t>
<code>
GetContainerNumSlots(bag)
</code>
<t>Если количество ячеек не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна пройти циклом по всем ячейкам и посчитать, сколько из них не пустые.</t>
<t>Ячейка считается не пустой, если:</t>
<code>
GetContainerItemLink(bag, slot)
</code>
<t>вернул значение, отличное от <k>nil</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountFilledSlotsInBag(bag)
]=],
requireKeywords = {
"CountFilledSlotsInBag",
"function",
"GetContainerNumSlots",
"GetContainerItemLink",
"for",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountFilledSlotsInBag) ~= "function" then
_G.checkError = "CountFilledSlotsInBag не является глобальной функцией"
return false
end
local function countExpected(bag)
if type(bag) ~= "number" then
return 0
end
local slots = GetContainerNumSlots(bag)
if type(slots) ~= "number" or slots < 0 then
return 0
end
local expected = 0
for slot = 1, slots do
if GetContainerItemLink(bag, slot) then
expected = expected + 1
end
end
return expected
end
local ok1, result1 = pcall(_G.CountFilledSlotsInBag, 0)
if not ok1 then
_G.checkError = "Ошибка вызова CountFilledSlotsInBag(0): " .. tostring(result1)
return false
end
local expected1 = countExpected(0)
if result1 ~= expected1 then
_G.checkError = "Количество занятых ячеек в сумке 0 не совпадает с ожидаемым"
return false
end
local ok2, result2 = pcall(_G.CountFilledSlotsInBag, -1)
if not ok2 or result2 ~= 0 then
_G.checkError = "Для сумки -1 функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.CountFilledSlotsInBag, "bad")
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нечислового bag функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][179] = {
type = "info",
title = "Информация о предмете",
helpModules = {173, 65},
content = [=[
<h>Информация о предмете</h>
<t>Функция <k>GetItemInfo</k> возвращает много данных о предмете: название, ссылку, качество, уровень предмета и другое.</t>
<code>
/run local name, link, quality, itemLevel = GetItemInfo(6948); print(name, link, quality, itemLevel)
</code>
<t>Здесь <n>6948</n> — это ID камня возвращения.</t>
<w>Важно:</w> если предмет ещё не загружен в кэш клиента, функция может вернуть <k>nil</k>.
<h>Что возвращает GetItemInfo</h>
<t>Основные значения:</t>
<c>name</c> — название предмета.
<c>link</c> — ссылка на предмет.
<c>quality</c> — числовое качество.
<c>itemLevel</c> — уровень предмета.
<c>reqLevel</c> — требуемый уровень.
<c>itemType</c> — тип предмета.
<c>itemSubType</c> — подтип предмета.
<c>stackCount</c> — максимальный размер стопки.
<h>Качество предмета</h>
<t>Качество обычно такое:</t>
<c>0</c> — бедный.
<c>1</c> — обычный.
<c>2</c> — необычный.
<c>3</c> — редкий.
<c>4</c> — эпический.
<c>5</c> — легендарный.
<h>Цвет качества</h>
<code>
/run local name, link, quality = GetItemInfo(6948); if name and ITEM_QUALITY_COLORS[quality] then print(ITEM_QUALITY_COLORS[quality].hex .. name .. "|r") end
</code>
<h>Количество предметов</h>
<code>
/run print(GetItemCount(6948))
</code>
<t>Функция <k>GetItemCount</k> возвращает количество таких предметов в сумках.</t>
<h>Безопасный шаблон</h>
<code>
/run local name, link, quality, itemLevel = GetItemInfo(6948); name = name or "Неизвестно"; itemLevel = itemLevel or 0; print(string.format("%s, ilvl %d", name, itemLevel))
</code>
]=],
}

ns_llua['lua'][180] = {
type = "vartest",
title = "Тест 179-1: камень возвращения",
helpModules = {179, 65},
tasks = {
{
var = "hearthstoneName",
desc = 'Создай глобальную переменную hearthstoneName = GetItemInfo(6948) or "Неизвестно"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "hearthstoneQuality",
desc = 'Создай глобальную переменную hearthstoneQuality = select(3, GetItemInfo(6948)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][181] = {
type = "vartest",
title = "Тест 179-2: количество и уровень предмета",
helpModules = {179, 65},
tasks = {
{
var = "hearthstoneCount",
desc = 'Создай глобальную переменную hearthstoneCount = GetItemCount(6948) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "hearthstoneItemLevel",
desc = 'Создай глобальную переменную hearthstoneItemLevel = select(4, GetItemInfo(6948)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][182] = {
type = "commenttest",
title = "Тест 179-3: функция GetItemNameSafe",
helpModules = {179, 45, 65},
preloadVars = {
{var = "GetItemNameSafe", desc = "GetItemNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 179-3: функция GetItemNameSafe</h>
<t>Создай глобальную функцию <k>GetItemNameSafe(itemID)</k>.</t>
<t>Если <k>itemID</k> не является числом, функция должна вернуть строку:</t>
<s>"Неизвестно"</s>
<t>Иначе функция должна получить имя предмета через:</t>
<code>
GetItemInfo(itemID)
</code>
<t>Если имя не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"Неизвестно"</s>
<t>Иначе функция должна вернуть имя предмета.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetItemNameSafe(itemID)
]=],
requireKeywords = {
"GetItemNameSafe",
"function",
"GetItemInfo",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetItemNameSafe) ~= "function" then
_G.checkError = "GetItemNameSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetItemNameSafe, 6948)
if not ok1 then
_G.checkError = "Ошибка вызова GetItemNameSafe(6948): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для itemID = 6948 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetItemNameSafe, "bad")
if not ok2 or result2 ~= "Неизвестно" then
_G.checkError = "Для нечислового itemID функция должна вернуть 'Неизвестно'"
return false
end
return true
end,
}

ns_llua['lua'][183] = {
type = "commenttest",
title = "Тест 179-4: функция GetItemQualitySafe",
helpModules = {179, 45, 65},
preloadVars = {
{var = "GetItemQualitySafe", desc = "GetItemQualitySafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 179-4: функция GetItemQualitySafe</h>
<t>Создай глобальную функцию <k>GetItemQualitySafe(itemID)</k>.</t>
<t>Если <k>itemID</k> не является числом, функция должна вернуть <n>-1</n>.</t>
<t>Иначе функция должна получить качество предмета через:</t>
<code>
select(3, GetItemInfo(itemID))
</code>
<t>Если качество не является числом или меньше нуля, функция должна вернуть <n>-1</n>.</t>
<t>Иначе функция должна вернуть качество предмета.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetItemQualitySafe(itemID)
]=],
requireKeywords = {
"GetItemQualitySafe",
"function",
"GetItemInfo",
"select",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetItemQualitySafe) ~= "function" then
_G.checkError = "GetItemQualitySafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetItemQualitySafe, 6948)
if not ok1 then
_G.checkError = "Ошибка вызова GetItemQualitySafe(6948): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < -1 or result1 > 5 then
_G.checkError = "Для itemID = 6948 функция должна вернуть число от -1 до 5"
return false
end
local ok2, result2 = pcall(_G.GetItemQualitySafe, "bad")
if not ok2 or result2 ~= -1 then
_G.checkError = "Для нечислового itemID функция должна вернуть -1"
return false
end
return true
end,
}

ns_llua['lua'][184] = {
type = "commenttest",
title = "Тест 179-5: функция GetItemCountSafe",
helpModules = {179, 45, 65},
preloadVars = {
{var = "GetItemCountSafe", desc = "GetItemCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 179-5: функция GetItemCountSafe</h>
<t>Создай глобальную функцию <k>GetItemCountSafe(itemID)</k>.</t>
<t>Если <k>itemID</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить количество предметов через:</t>
<code>
GetItemCount(itemID)
</code>
<t>Если количество не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество предметов.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetItemCountSafe(itemID)
]=],
requireKeywords = {
"GetItemCountSafe",
"function",
"GetItemCount",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetItemCountSafe) ~= "function" then
_G.checkError = "GetItemCountSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetItemCountSafe, 6948)
if not ok1 then
_G.checkError = "Ошибка вызова GetItemCountSafe(6948): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 then
_G.checkError = "Для itemID = 6948 функция должна вернуть число больше или равное нулю"
return false
end
local ok2, result2 = pcall(_G.GetItemCountSafe, "bad")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для нечислового itemID функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][185] = {
type = "info",
title = "Экипировка игрока",
helpModules = {179, 173, 65},
content = [=[
<h>Экипировка игрока</h>
<t>Экипировка доступна через слоты. У каждого слота есть строковое имя.</t>
<h>Основные слоты</h>
<c>"HeadSlot"</c> — голова.
<c>"NeckSlot"</c> — шея.
<c>"ShoulderSlot"</c> — плечи.
<c>"BackSlot"</c> — спина.
<c>"ChestSlot"</c> — грудь.
<c>"WristSlot"</c> — запястья.
<c>"HandsSlot"</c> — руки.
<c>"WaistSlot"</c> — пояс.
<c>"LegsSlot"</c> — ноги.
<c>"FeetSlot"</c> — ступни.
<c>"Finger0Slot"</c> — первое кольцо.
<c>"Finger1Slot"</c> — второе кольцо.
<c>"Trinket0Slot"</c> — первая бижутерия.
<c>"Trinket1Slot"</c> — вторая бижутерия.
<c>"MainHandSlot"</c> — правая рука.
<c>"SecondaryHandSlot"</c> — левая рука.
<h>GetInventorySlotInfo</h>
<code>
/run local slotId = GetInventorySlotInfo("HeadSlot"); print(slotId)
</code>
<t>Функция возвращает числовой ID слота.</t>
<h>Предмет в слоте</h>
<code>
/run local slotId = GetInventorySlotInfo("HeadSlot"); local link = GetInventoryItemLink("player", slotId); print(link or "Пусто")
</code>
<h>Количество предметов в слоте</h>
<code>
/run local slotId = GetInventorySlotInfo("MainHandSlot"); print(GetInventoryItemCount("player", slotId))
</code>
<h>Текстура предмета</h>
<code>
/run local slotId = GetInventorySlotInfo("ChestSlot"); print(GetInventoryItemTexture("player", slotId))
</code>
<h>Перебор нескольких слотов</h>
<code>
/run local slots = {"HeadSlot", "ChestSlot", "MainHandSlot"}; for _, slotName in ipairs(slots) do local slotId = GetInventorySlotInfo(slotName); local link = GetInventoryItemLink("player", slotId); print(slotName, link or "пусто") end
</code>
]=],
}

ns_llua['lua'][186] = {
type = "vartest",
title = "Тест 185-1: ID слотов экипировки",
helpModules = {185, 65},
tasks = {
{
var = "headSlotID",
desc = 'Создай глобальную переменную headSlotID = GetInventorySlotInfo("HeadSlot") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "chestSlotID",
desc = 'Создай глобальную переменную chestSlotID = GetInventorySlotInfo("ChestSlot") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][187] = {
type = "vartest",
title = "Тест 185-2: предметы в слотах",
helpModules = {185, 65},
tasks = {
{
var = "headItemLink",
desc = 'Создай глобальную переменную headItemLink = GetInventoryItemLink("player", GetInventorySlotInfo("HeadSlot")) or "empty"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "mainHandItemLink",
desc = 'Создай глобальную переменную mainHandItemLink = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot")) or "empty"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][188] = {
type = "commenttest",
title = "Тест 185-3: функция GetInventorySlotIDSafe",
helpModules = {185, 45, 65},
preloadVars = {
{var = "GetInventorySlotIDSafe", desc = "GetInventorySlotIDSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 185-3: функция GetInventorySlotIDSafe</h>
<t>Создай глобальную функцию <k>GetInventorySlotIDSafe(slotName)</k>.</t>
<t>Если <k>slotName</k> не является строкой, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить ID слота через:</t>
<code>
GetInventorySlotInfo(slotName)
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть ID слота.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetInventorySlotIDSafe(slotName)
]=],
requireKeywords = {
"GetInventorySlotIDSafe",
"function",
"GetInventorySlotInfo",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetInventorySlotIDSafe) ~= "function" then
_G.checkError = "GetInventorySlotIDSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetInventorySlotIDSafe, "HeadSlot")
if not ok1 then
_G.checkError = "Ошибка вызова GetInventorySlotIDSafe('HeadSlot'): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 <= 0 then
_G.checkError = "Для HeadSlot функция должна вернуть число больше нуля"
return false
end
local ok2, result2 = pcall(_G.GetInventorySlotIDSafe, "BadSlot")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для BadSlot функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.GetInventorySlotIDSafe, 123)
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нестрокового slotName функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][189] = {
type = "commenttest",
title = "Тест 185-4: функция GetInventoryItemLinkSafe",
helpModules = {185, 45, 65},
preloadVars = {
{var = "GetInventoryItemLinkSafe", desc = "GetInventoryItemLinkSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 185-4: функция GetInventoryItemLinkSafe</h>
<t>Создай глобальную функцию <k>GetInventoryItemLinkSafe(slotName)</k>.</t>
<t>Если <k>slotName</k> не является строкой, функция должна вернуть строку:</t>
<s>"empty"</s>
<t>Иначе функция должна получить ID слота через:</t>
<code>
GetInventorySlotInfo(slotName)
</code>
<t>Если ID слота не является числом или меньше нуля, функция должна вернуть:</t>
<s>"empty"</s>
<t>Иначе функция должна получить ссылку на предмет через:</t>
<code>
GetInventoryItemLink("player", slotID)
</code>
<t>Если ссылка не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"empty"</s>
<t>Иначе функция должна вернуть ссылку на предмет.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetInventoryItemLinkSafe(slotName)
]=],
requireKeywords = {
"GetInventoryItemLinkSafe",
"function",
"GetInventorySlotInfo",
"GetInventoryItemLink",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetInventoryItemLinkSafe) ~= "function" then
_G.checkError = "GetInventoryItemLinkSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetInventoryItemLinkSafe, "HeadSlot")
if not ok1 then
_G.checkError = "Ошибка вызова GetInventoryItemLinkSafe('HeadSlot'): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для HeadSlot функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetInventoryItemLinkSafe, "BadSlot")
if not ok2 or result2 ~= "empty" then
_G.checkError = "Для BadSlot функция должна вернуть 'empty'"
return false
end
local ok3, result3 = pcall(_G.GetInventoryItemLinkSafe, 123)
if not ok3 or result3 ~= "empty" then
_G.checkError = "Для нестрокового slotName функция должна вернуть 'empty'"
return false
end
return true
end,
}

ns_llua['lua'][190] = {
type = "commenttest",
title = "Тест 185-5: функция CountEquippedSlots",
helpModules = {185, 45, 31, 65},
preloadVars = {
{var = "CountEquippedSlots", desc = "CountEquippedSlots очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 185-5: функция CountEquippedSlots</h>
<t>Создай глобальную функцию <k>CountEquippedSlots(slotNames)</k>.</t>
<t>Аргумент <k>slotNames</k> — это таблица со строками-названиями слотов экипировки.</t>
<t>Если <k>slotNames</k> не является таблицей, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна пройти по таблице через <k>ipairs</k> и посчитать, сколько слотов содержат предмет.</t>
<t>Для каждого имени слота используй:</t>
<c>GetInventorySlotInfo(slotName)</c>
<c>GetInventoryItemLink("player", slotID)</c>
<t>Слот считается надетым, если ссылка на предмет является непустой строкой.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountEquippedSlots(slotNames)
]=],
requireKeywords = {
"CountEquippedSlots",
"function",
"ipairs",
"GetInventorySlotInfo",
"GetInventoryItemLink",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountEquippedSlots) ~= "function" then
_G.checkError = "CountEquippedSlots не является глобальной функцией"
return false
end
local function expectedCount(slotNames)
if type(slotNames) ~= "table" then
return 0
end
local expected = 0
for _, slotName in ipairs(slotNames) do
if type(slotName) == "string" then
local slotID = GetInventorySlotInfo(slotName)
if type(slotID) == "number" and slotID >= 0 then
local link = GetInventoryItemLink("player", slotID)
if type(link) == "string" and link ~= "" then
expected = expected + 1
end
end
end
end
return expected
end
local tests = {
{
input = {"HeadSlot", "ChestSlot"},
},
{
input = {},
},
{
input = "bad",
},
}
for i, test in ipairs(tests) do
local expected = expectedCount(test.input)
local ok, result = pcall(_G.CountEquippedSlots, test.input)
if not ok or result ~= expected then
_G.checkError = "Тест " .. i .. " функции CountEquippedSlots не пройден"
return false
end
end
return true
end,
}

ns_llua['lua'][191] = {
type = "info",
title = "Информация о заклинаниях",
helpModules = {65, 45, 10},
content = [=[
<h>Информация о заклинаниях</h>
<t>Функция <k>GetSpellInfo</k> возвращает данные о заклинании по ID или названию.</t>
<code>
/run local name, rank, icon, cost, isFunnel, powerType, castTime = GetSpellInfo(6603); print(name, castTime)
</code>
<t>Здесь <n>6603</n> — ID базовой автоматической атаки.</t>
<w>Важно:</w> если заклинание неизвестно или данные ещё не доступны, функция может вернуть <k>nil</k>.
<h>Что возвращает GetSpellInfo</h>
<t>Основные значения:</t>
<c>name</c> — название заклинания.
<c>rank</c> — ранг.
<c>icon</c> — иконка.
<c>cost</c> — стоимость.
<c>powerType</c> — тип ресурса.
<c>castTime</c> — время каста в миллисекундах.
<h>SpellID лучше названия</h>
<t>Название заклинания зависит от языка клиента:</t>
<code>
/run print(GetSpellInfo(6603))
</code>
<t>ID заклинания одинаковый для всех клиентов, поэтому для логики лучше использовать ID.</t>
<h>Иконка заклинания</h>
<code>
/run print(GetSpellTexture(6603))
</code>
<h>Безопасный шаблон</h>
<code>
/run local name = GetSpellInfo(6603) or "Неизвестно"; print(name)
</code>
]=],
}

ns_llua['lua'][192] = {
type = "vartest",
title = "Тест 191-1: имя и иконка заклинания",
helpModules = {191, 65},
tasks = {
{
var = "spellName",
desc = 'Создай глобальную переменную spellName = GetSpellInfo(6603) or "Неизвестно"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "spellTexture",
desc = 'Создай глобальную переменную spellTexture = GetSpellTexture(6603) or ""',
check = function(value)
return type(value) == "string"
end,
},
},
}

ns_llua['lua'][193] = {
type = "vartest",
title = "Тест 191-2: стоимость и время каста",
helpModules = {191, 65},
tasks = {
{
var = "spellCost",
desc = 'Создай глобальную переменную spellCost = select(4, GetSpellInfo(6603)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "spellCastTime",
desc = 'Создай глобальную переменную spellCastTime = select(7, GetSpellInfo(6603)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][194] = {
type = "commenttest",
title = "Тест 191-3: функция GetSpellNameSafe",
helpModules = {191, 45, 65},
preloadVars = {
{var = "GetSpellNameSafe", desc = "GetSpellNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 191-3: функция GetSpellNameSafe</h>
<t>Создай глобальную функцию <k>GetSpellNameSafe(spellID)</k>.</t>
<t>Если <k>spellID</k> не является числом, функция должна вернуть строку:</t>
<s>"Неизвестно"</s>
<t>Иначе функция должна получить имя заклинания через:</t>
<code>
GetSpellInfo(spellID)
</code>
<t>Если имя не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"Неизвестно"</s>
<t>Иначе функция должна вернуть имя заклинания.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSpellNameSafe(spellID)
]=],
requireKeywords = {
"GetSpellNameSafe",
"function",
"GetSpellInfo",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSpellNameSafe) ~= "function" then
_G.checkError = "GetSpellNameSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetSpellNameSafe, 6603)
if not ok1 then
_G.checkError = "Ошибка вызова GetSpellNameSafe(6603): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для spellID = 6603 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetSpellNameSafe, "bad")
if not ok2 or result2 ~= "Неизвестно" then
_G.checkError = "Для нечислового spellID функция должна вернуть 'Неизвестно'"
return false
end
return true
end,
}

ns_llua['lua'][195] = {
type = "commenttest",
title = "Тест 191-4: функция GetSpellTextureSafe",
helpModules = {191, 45, 65},
preloadVars = {
{var = "GetSpellTextureSafe", desc = "GetSpellTextureSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 191-4: функция GetSpellTextureSafe</h>
<t>Создай глобальную функцию <k>GetSpellTextureSafe(spellID)</k>.</t>
<t>Если <k>spellID</k> не является числом, функция должна вернуть строку:</t>
<s>"empty"</s>
<t>Иначе функция должна получить иконку заклинания через:</t>
<code>
GetSpellTexture(spellID)
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"empty"</s>
<t>Иначе функция должна вернуть путь к иконке.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSpellTextureSafe(spellID)
]=],
requireKeywords = {
"GetSpellTextureSafe",
"function",
"GetSpellTexture",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSpellTextureSafe) ~= "function" then
_G.checkError = "GetSpellTextureSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetSpellTextureSafe, 6603)
if not ok1 then
_G.checkError = "Ошибка вызова GetSpellTextureSafe(6603): " .. tostring(result1)
return false
end
if type(result1) ~= "string" then
_G.checkError = "Для spellID = 6603 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetSpellTextureSafe, "bad")
if not ok2 or result2 ~= "empty" then
_G.checkError = "Для нечислового spellID функция должна вернуть 'empty'"
return false
end
return true
end,
}

ns_llua['lua'][196] = {
type = "commenttest",
title = "Тест 191-5: функция GetSpellCastTimeSafe",
helpModules = {191, 45, 65},
preloadVars = {
{var = "GetSpellCastTimeSafe", desc = "GetSpellCastTimeSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 191-5: функция GetSpellCastTimeSafe</h>
<t>Создай глобальную функцию <k>GetSpellCastTimeSafe(spellID)</k>.</t>
<t>Если <k>spellID</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить время каста через:</t>
<code>
select(7, GetSpellInfo(spellID))
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть время каста.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSpellCastTimeSafe(spellID)
]=],
requireKeywords = {
"GetSpellCastTimeSafe",
"function",
"GetSpellInfo",
"select",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSpellCastTimeSafe) ~= "function" then
_G.checkError = "GetSpellCastTimeSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetSpellCastTimeSafe, 6603)
if not ok1 then
_G.checkError = "Ошибка вызова GetSpellCastTimeSafe(6603): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 then
_G.checkError = "Для spellID = 6603 функция должна вернуть число больше или равное нулю"
return false
end
local ok2, result2 = pcall(_G.GetSpellCastTimeSafe, "bad")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для нечислового spellID функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][197] = {
type = "info",
title = "Кулдауны заклинаний",
helpModules = {191, 65, 10},
content = [=[
<h>Кулдауны заклинаний</h>
<t>Функция <k>GetSpellCooldown</k> возвращает информацию о восстановлении заклинания.</t>
<code>
/run local start, duration = GetSpellCooldown(6603); print(start, duration)
</code>
<h>Что означают значения</h>
<c>start</c> — момент начала кулдауна по <k>GetTime</k>.
<c>duration</c> — длительность кулдауна в секундах.
<c>enabled</c> — доступно ли заклинание.
<h>Если заклинание готово</h>
<t>Обычно если <k>start</k> равно <n>0</n>, кулдауна нет.</t>
<code>
/run local start, duration = GetSpellCooldown(6603); if start == 0 then print("Готово") else print("Кулдаун") end
</code>
<h>Остаток времени</h>
<code>
/run local start, duration = GetSpellCooldown(6603); local remaining = 0; if start and duration and start > 0 then remaining = start + duration - GetTime(); if remaining < 0 then remaining = 0 end end; print(string.format("Осталось: %.1f", remaining))
</code>
<h>Безопасный шаблон</h>
<code>
/run local start = GetSpellCooldown(6603) or 0; if start == 0 then print("Кулдауна нет") end
</code>
]=],
}

ns_llua['lua'][198] = {
type = "vartest",
title = "Тест 197-1: старт и длительность кулдауна",
helpModules = {197, 65},
tasks = {
{
var = "spellCooldownStart",
desc = 'Создай глобальную переменную spellCooldownStart = GetSpellCooldown(6603) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "spellCooldownDuration",
desc = 'Создай глобальную переменную spellCooldownDuration = select(2, GetSpellCooldown(6603)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][199] = {
type = "vartest",
title = "Тест 197-2: готовность заклинания",
helpModules = {197, 15, 65},
tasks = {
{
var = "spellIsReady",
desc = 'Создай глобальную переменную spellIsReady = ((GetSpellCooldown(6603) or 0) == 0)',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "spellCooldownEnabled",
desc = 'Создай глобальную переменную spellCooldownEnabled = select(3, GetSpellCooldown(6603)) or 1',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][200] = {
type = "commenttest",
title = "Тест 197-3: функция GetSpellCooldownStartSafe",
helpModules = {197, 45, 65},
preloadVars = {
{var = "GetSpellCooldownStartSafe", desc = "GetSpellCooldownStartSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 197-3: функция GetSpellCooldownStartSafe</h>
<t>Создай глобальную функцию <k>GetSpellCooldownStartSafe(spellID)</k>.</t>
<t>Если <k>spellID</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить старт кулдауна через:</t>
<code>
GetSpellCooldown(spellID)
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть старт кулдауна.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSpellCooldownStartSafe(spellID)
]=],
requireKeywords = {
"GetSpellCooldownStartSafe",
"function",
"GetSpellCooldown",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSpellCooldownStartSafe) ~= "function" then
_G.checkError = "GetSpellCooldownStartSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetSpellCooldownStartSafe, 6603)
if not ok1 then
_G.checkError = "Ошибка вызова GetSpellCooldownStartSafe(6603): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 then
_G.checkError = "Для spellID = 6603 функция должна вернуть число больше или равное нулю"
return false
end
local ok2, result2 = pcall(_G.GetSpellCooldownStartSafe, "bad")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для нечислового spellID функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][201] = {
type = "commenttest",
title = "Тест 197-4: функция GetSpellCooldownDurationSafe",
helpModules = {197, 45, 65},
preloadVars = {
{var = "GetSpellCooldownDurationSafe", desc = "GetSpellCooldownDurationSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 197-4: функция GetSpellCooldownDurationSafe</h>
<t>Создай глобальную функцию <k>GetSpellCooldownDurationSafe(spellID)</k>.</t>
<t>Если <k>spellID</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить длительность кулдауна через:</t>
<code>
select(2, GetSpellCooldown(spellID))
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть длительность кулдауна.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSpellCooldownDurationSafe(spellID)
]=],
requireKeywords = {
"GetSpellCooldownDurationSafe",
"function",
"GetSpellCooldown",
"select",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSpellCooldownDurationSafe) ~= "function" then
_G.checkError = "GetSpellCooldownDurationSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetSpellCooldownDurationSafe, 6603)
if not ok1 then
_G.checkError = "Ошибка вызова GetSpellCooldownDurationSafe(6603): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 then
_G.checkError = "Для spellID = 6603 функция должна вернуть число больше или равное нулю"
return false
end
local ok2, result2 = pcall(_G.GetSpellCooldownDurationSafe, "bad")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для нечислового spellID функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][202] = {
type = "commenttest",
title = "Тест 197-5: функция GetSpellCooldownRemaining",
helpModules = {197, 45, 10, 65},
preloadVars = {
{var = "GetSpellCooldownRemaining", desc = "GetSpellCooldownRemaining очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 197-5: функция GetSpellCooldownRemaining</h>
<t>Создай глобальную функцию <k>GetSpellCooldownRemaining(spellID)</k>.</t>
<t>Если <k>spellID</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить <k>start</k> и <k>duration</k> через:</t>
<code>
GetSpellCooldown(spellID)
</code>
<t>Если <k>start</k> не является числом или равен нулю, функция должна вернуть <n>0</n>.</t>
<t>Если <k>duration</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна посчитать остаток:</t>
<code>
start + duration - GetTime()
</code>
<t>Если остаток меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть остаток.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSpellCooldownRemaining(spellID)
]=],
requireKeywords = {
"GetSpellCooldownRemaining",
"function",
"GetSpellCooldown",
"GetTime",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSpellCooldownRemaining) ~= "function" then
_G.checkError = "GetSpellCooldownRemaining не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetSpellCooldownRemaining, 6603)
if not ok1 then
_G.checkError = "Ошибка вызова GetSpellCooldownRemaining(6603): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 or result1 > 1000000 then
_G.checkError = "Для spellID = 6603 функция должна вернуть число от 0 до 1000000"
return false
end
local ok2, result2 = pcall(_G.GetSpellCooldownRemaining, "bad")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для нечислового spellID функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][203] = {
type = "info",
title = "Баффы и дебаффы глубже",
helpModules = {107, 65, 45},
content = [=[
<h>Баффы и дебаффы глубже</h>
<t>Раньше мы получали только имя баффа или дебаффа. Теперь разберём дополнительные данные: стаки, длительность и время окончания.</t>
<h>UnitAura</h>
<code>
/run local name, rank, icon, count, debuffType, duration, expiration = UnitAura("player", 1, "HELPFUL"); print(name, count, duration, expiration)
</code>
<h>Основные возвращаемые значения</h>
<c>name</c> — название ауры.
<c>rank</c> — ранг.
<c>icon</c> — иконка.
<c>count</c> — количество стаков.
<c>debuffType</c> — тип дебаффа.
<c>duration</c> — длительность в секундах.
<c>expirationTime</c> — время окончания по <k>GetTime</k>.
<h>Баффы и дебаффы</h>
<code>
/run local name = UnitBuff("player", 1); print(name or "нет")
</code>
<code>
/run local name = UnitDebuff("player", 1); print(name or "нет")
</code>
<h>Остаток времени</h>
<code>
/run local name, _, _, _, _, duration, expiration = UnitBuff("player", 1); if name and expiration and expiration > 0 then print(name, math.floor(expiration - GetTime())) else print("Таймера нет") end
</code>
<t>Если <k>duration</k> и <k>expirationTime</k> равны нулю, таймер у ауры может отсутствовать.</t>
<h>Фильтры</h>
<c>"HELPFUL"</c> — баффы.
<c>"HARMFUL"</c> — дебаффы.
<t>Фильтры можно комбинировать, например искать только свои ауры, но в простых случаях достаточно <c>"HELPFUL"</c> и <c>"HARMFUL"</c>.</t>
]=],
}

ns_llua['lua'][204] = {
type = "vartest",
title = "Тест 203-1: первый бафф игрока",
helpModules = {203, 65},
tasks = {
{
var = "firstBuffName",
desc = 'Создай глобальную переменную firstBuffName = UnitBuff("player", 1) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "firstBuffCount",
desc = 'Создай глобальную переменную firstBuffCount = select(4, UnitBuff("player", 1)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][205] = {
type = "vartest",
title = "Тест 203-2: первый дебафф игрока",
helpModules = {203, 65},
tasks = {
{
var = "firstDebuffName",
desc = 'Создай глобальную переменную firstDebuffName = UnitDebuff("player", 1) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "firstDebuffType",
desc = 'Создай глобальную переменную firstDebuffType = select(5, UnitDebuff("player", 1)) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][206] = {
type = "commenttest",
title = "Тест 203-3: функция GetAuraNameSafe",
helpModules = {203, 45, 65},
preloadVars = {
{var = "GetAuraNameSafe", desc = "GetAuraNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 203-3: функция GetAuraNameSafe</h>
<t>Создай глобальную функцию <k>GetAuraNameSafe(unit, index)</k>.</t>
<t>Если <k>unit</k> не является строкой или <k>index</k> не является числом, функция должна вернуть строку:</t>
<s>"нет"</s>
<t>Иначе функция должна получить имя баффа через:</t>
<code>
UnitBuff(unit, index)
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"нет"</s>
<t>Иначе функция должна вернуть имя баффа.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetAuraNameSafe(unit, index)
]=],
requireKeywords = {
"GetAuraNameSafe",
"function",
"UnitBuff",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetAuraNameSafe) ~= "function" then
_G.checkError = "GetAuraNameSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetAuraNameSafe, "player", 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetAuraNameSafe('player', 1): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для player и index = 1 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetAuraNameSafe, "ns_invalid_unit", 1)
if not ok2 or result2 ~= "нет" then
_G.checkError = "Для несуществующего юнита функция должна вернуть 'нет'"
return false
end
local ok3, result3 = pcall(_G.GetAuraNameSafe, "player", "bad")
if not ok3 or result3 ~= "нет" then
_G.checkError = "Для нечислового index функция должна вернуть 'нет'"
return false
end
return true
end,
}

ns_llua['lua'][207] = {
type = "commenttest",
title = "Тест 203-4: функция GetAuraRemainingSafe",
helpModules = {203, 45, 10, 65},
preloadVars = {
{var = "GetAuraRemainingSafe", desc = "GetAuraRemainingSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 203-4: функция GetAuraRemainingSafe</h>
<t>Создай глобальную функцию <k>GetAuraRemainingSafe(unit, index)</k>.</t>
<t>Если <k>unit</k> не является строкой или <k>index</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить данные баффа через:</t>
<code>
UnitBuff(unit, index)
</code>
<t>Из полученных данных используй имя, длительность и время окончания.</t>
<t>Если имени нет, функция должна вернуть <n>0</n>.</t>
<t>Если время окончания не является числом или меньше либо равно нулю, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть остаток времени:</t>
<code>
expirationTime - GetTime()
</code>
<t>Если остаток меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetAuraRemainingSafe(unit, index)
]=],
requireKeywords = {
"GetAuraRemainingSafe",
"function",
"UnitBuff",
"GetTime",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetAuraRemainingSafe) ~= "function" then
_G.checkError = "GetAuraRemainingSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetAuraRemainingSafe, "player", 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetAuraRemainingSafe('player', 1): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 then
_G.checkError = "Для player и index = 1 функция должна вернуть число больше или равное нулю"
return false
end
local ok2, result2 = pcall(_G.GetAuraRemainingSafe, "ns_invalid_unit", 1)
if not ok2 or result2 ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.GetAuraRemainingSafe, "player", "bad")
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нечислового index функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][208] = {
type = "commenttest",
title = "Тест 203-5: функция CountAurasWithFilter",
helpModules = {203, 45, 31, 65},
preloadVars = {
{var = "CountAurasWithFilter", desc = "CountAurasWithFilter очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 203-5: функция CountAurasWithFilter</h>
<t>Создай глобальную функцию <k>CountAurasWithFilter(unit, filter)</k>.</t>
<t>Если <k>unit</k> не является строкой или <k>filter</k> не является строкой, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна посчитать количество аур юнита с указанным фильтром.</t>
<t>Используй:</t>
<code>
UnitAura(unit, index, filter)
</code>
<t>Проверяй индексы от 1 до 40.</t>
<t>Если <k>UnitAura</k> вернул <k>nil</k>, прекрати подсчёт.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountAurasWithFilter(unit, filter)
]=],
requireKeywords = {
"CountAurasWithFilter",
"function",
"UnitAura",
"for",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountAurasWithFilter) ~= "function" then
_G.checkError = "CountAurasWithFilter не является глобальной функцией"
return false
end
local function countExpected(unit, filter)
if type(unit) ~= "string" or type(filter) ~= "string" then
return 0
end
local count = 0
for i = 1, 40 do
if not UnitAura(unit, i, filter) then
break
end
count = count + 1
end
return count
end
local expected1 = countExpected("player", "HELPFUL")
local ok1, result1 = pcall(_G.CountAurasWithFilter, "player", "HELPFUL")
if not ok1 or result1 ~= expected1 then
_G.checkError = "Для player и фильтра HELPFUL функция вернула неверное количество"
return false
end
local ok2, result2 = pcall(_G.CountAurasWithFilter, "ns_invalid_unit", "HELPFUL")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.CountAurasWithFilter, "player", 123)
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нестрокового фильтра функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][209] = {
type = "info",
title = "Каст, каналы и угроза",
helpModules = {197, 203},
content = [=[
<h>Каст, каналы и угроза</h>
<t>WoW API позволяет проверить, кастует ли юнит заклинание или поддерживает канальное заклинание.</t>
<h>UnitCastingInfo</h>
<code>
/run local name, rank, text, startTime, endTime = UnitCastingInfo("player"); print(name or "нет")
</code>
<t>Если игрок ничего не кастует, функция вернёт <k>nil</k>.</t>
<h>UnitChannelInfo</h>
<t>Для канальных заклинаний используется <k>UnitChannelInfo</k>.</t>
<code>
/run local name, rank, text, startTime, endTime = UnitChannelInfo("player"); print(name or "нет")
</code>
<h>Время каста</h>
<t>Значения <k>startTime</k> и <k>endTime</k> обычно возвращаются в миллисекундах.</t>
<t><k>GetTime()</k> возвращает время в секундах, поэтому для сравнения секунды нужно умножить на 1000.</t>
<code>
/run local name, _, _, startTime, endTime = UnitCastingInfo("player"); if name then local remaining = (endTime / 1000) - GetTime(); print(string.format("Осталось: %.1f", remaining)) end
</code>
<h>UnitThreatSituation</h>
<t>Возвращает примерный статус угрозы.</t>
<code>
/run print(UnitThreatSituation("player"))
</code>
<h>InCombatLockdown</h>
<t>Показывает, находится ли интерфейс в состоянии боя с ограничениями.</t>
<code>
/run if InCombatLockdown() then print("Блокировка боя") else print("Вне блокировки") end
</code>
<w>Важно:</w> в бою многие действия интерфейса защищены. Позже мы отдельно разберём защищённые кнопки.
]=],
}

ns_llua['lua'][210] = {
type = "vartest",
title = "Тест 209-1: каст и канал игрока",
helpModules = {209, 65},
tasks = {
{
var = "playerCastName",
desc = 'Создай глобальную переменную playerCastName = UnitCastingInfo("player") or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "playerChannelName",
desc = 'Создай глобальную переменную playerChannelName = UnitChannelInfo("player") or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][211] = {
type = "vartest",
title = "Тест 209-2: время каста",
helpModules = {209, 65},
tasks = {
{
var = "playerCastStart",
desc = 'Создай глобальную переменную playerCastStart = select(4, UnitCastingInfo("player")) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerCastEnd",
desc = 'Создай глобальную переменную playerCastEnd = select(5, UnitCastingInfo("player")) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][212] = {
type = "commenttest",
title = "Тест 209-3: функция GetCastNameSafe",
helpModules = {209, 45, 65},
preloadVars = {
{var = "GetCastNameSafe", desc = "GetCastNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 209-3: функция GetCastNameSafe</h>
<t>Создай глобальную функцию <k>GetCastNameSafe(unit)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть строку:</t>
<s>"нет"</s>
<t>Иначе функция должна сначала попробовать получить имя обычного каста через:</t>
<code>
UnitCastingInfo(unit)
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна попробовать получить имя канального заклинания через:</t>
<code>
UnitChannelInfo(unit)
</code>
<t>Если и этот результат не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"нет"</s>
<t>Иначе функция должна вернуть имя заклинания.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetCastNameSafe(unit)
]=],
requireKeywords = {
"GetCastNameSafe",
"function",
"UnitCastingInfo",
"UnitChannelInfo",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetCastNameSafe) ~= "function" then
_G.checkError = "GetCastNameSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetCastNameSafe, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetCastNameSafe('player'): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для player функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetCastNameSafe, "ns_invalid_unit")
if not ok2 or result2 ~= "нет" then
_G.checkError = "Для несуществующего юнита функция должна вернуть 'нет'"
return false
end
return true
end,
}

ns_llua['lua'][213] = {
type = "commenttest",
title = "Тест 209-4: функция GetCastProgressSafe",
helpModules = {209, 45, 10, 65},
preloadVars = {
{var = "GetCastProgressSafe", desc = "GetCastProgressSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 209-4: функция GetCastProgressSafe</h>
<t>Создай глобальную функцию <k>GetCastProgressSafe(unit)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить данные каста через:</t>
<code>
UnitCastingInfo(unit)
</code>
<t>Если обычного каста нет, функция должна попробовать:</t>
<code>
UnitChannelInfo(unit)
</code>
<t>Если имя каста не получено, функция должна вернуть <n>0</n>.</t>
<t>Если <k>startTime</k> или <k>endTime</k> не являются числами, функция должна вернуть <n>0</n>.</t>
<t>Если <k>endTime</k> меньше или равен <k>startTime</k>, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть процент прогресса от 0 до 100.</t>
<t>Формула:</t>
<code>
(GetTime() * 1000 - startTime) / (endTime - startTime) * 100
</code>
<t>Если результат меньше нуля, верни <n>0</n>.</t>
<t>Если результат больше 100, верни <n>100</n>.</t>
<t>Используй <k>math.floor</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetCastProgressSafe(unit)
]=],
requireKeywords = {
"GetCastProgressSafe",
"function",
"UnitCastingInfo",
"UnitChannelInfo",
"GetTime",
"math.floor",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetCastProgressSafe) ~= "function" then
_G.checkError = "GetCastProgressSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetCastProgressSafe, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetCastProgressSafe('player'): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 or result1 > 100 then
_G.checkError = "Для player функция должна вернуть число от 0 до 100"
return false
end
local ok2, result2 = pcall(_G.GetCastProgressSafe, "ns_invalid_unit")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][214] = {
type = "commenttest",
title = "Тест 209-5: функция GetThreatStatusSafe",
helpModules = {209, 45, 65},
preloadVars = {
{var = "GetThreatStatusSafe", desc = "GetThreatStatusSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 209-5: функция GetThreatStatusSafe</h>
<t>Создай глобальную функцию <k>GetThreatStatusSafe(unit)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть <n>-1</n>.</t>
<t>Иначе функция должна получить статус угрозы через:</t>
<code>
UnitThreatSituation(unit)
</code>
<t>Если результат не является числом или меньше нуля или больше 3, функция должна вернуть <n>-1</n>.</t>
<t>Иначе функция должна вернуть статус угрозы.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetThreatStatusSafe(unit)
]=],
requireKeywords = {
"GetThreatStatusSafe",
"function",
"UnitThreatSituation",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetThreatStatusSafe) ~= "function" then
_G.checkError = "GetThreatStatusSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetThreatStatusSafe, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetThreatStatusSafe('player'): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < -1 or result1 > 3 then
_G.checkError = "Для player функция должна вернуть число от -1 до 3"
return false
end
local ok2, result2 = pcall(_G.GetThreatStatusSafe, "ns_invalid_unit")
if not ok2 or result2 ~= -1 then
_G.checkError = "Для несуществующего юнита функция должна вернуть -1"
return false
end
return true
end,
}

ns_llua['lua'][215] = {
type = "info",
title = "Фреймы как объекты",
helpModules = {45, 44},
content = [=[
<h>Фреймы как объекты</h>
<t>С этого момента мы начинаем работать с интерфейсом. Основной строительный блок интерфейса WoW — фрейм.</t>
<t>Фрейм — это объект. У него есть методы.</t>
<h>CreateFrame</h>
<code>
MyFirstFrame = CreateFrame("Frame", "MyFirstFrame", UIParent)
</code>
<t>Аргументы:</t>
<c>"Frame"</c> — тип фрейма.
<c>"MyFirstFrame"</c> — глобальное имя.
<c>UIParent</c> — родитель.
<h>Глобальное имя</h>
<t>Если второй аргумент не <k>nil</k>, WoW создаст глобальную переменную с таким именем.</t>
<code>
print(type(MyFirstFrame))
</code>
<h>Методы через двоеточие</h>
<t>Методы объекта вызываются через двоеточие:</t>
<code>
MyFirstFrame:SetSize(200, 100)
MyFirstFrame:SetPoint("CENTER")
MyFirstFrame:Show()
MyFirstFrame:Hide()
</code>
<t>Запись через двоеточие примерно означает, что фрейм сам передаётся внутрь метода.</t>
<code>
MyFirstFrame.Show(MyFirstFrame)
</code>
<h>Показать и скрыть</h>
<code>
MyFirstFrame:Show()
</code>
<code>
MyFirstFrame:Hide()
</code>
<code>
print(MyFirstFrame:IsShown())
</code>
<w>Важно:</w> пока фрейму не заданы размер и позиция, он может быть невидим или находиться в неожиданном месте.
]=],
}

ns_llua['lua'][216] = {
type = "commenttest",
title = "Тест 215-1: первый фрейм",
helpModules = {215},
preloadVars = {
{var = "CourseTestFrame", desc = "CourseTestFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 215-1: первый фрейм</h>
<t>Создай глобальный фрейм <k>CourseTestFrame</k>.</t>
<t>Используй:</t>
<code>
CourseTestFrame = CreateFrame("Frame", "CourseTestFrame", UIParent)
</code>
<t>Размер и позиция не нужны.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseTestFrame
]=],
requireKeywords = {
"CourseTestFrame",
"CreateFrame",
"Frame",
"UIParent",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseTestFrame
if not f then
_G.checkError = "CourseTestFrame не был создан"
return false
end
if type(f.Show) ~= "function" or type(f.Hide) ~= "function" or type(f.IsShown) ~= "function" then
_G.checkError = "CourseTestFrame не похож на фрейм"
return false
end
if f.GetName and f:GetName() ~= "CourseTestFrame" then
_G.checkError = "Фрейм должен иметь глобальное имя CourseTestFrame"
return false
end
return true
end,
}

ns_llua['lua'][217] = {
type = "commenttest",
title = "Тест 215-2: видимый фрейм",
helpModules = {215},
preloadVars = {
{var = "CourseFrameShown", desc = "CourseFrameShown очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 215-2: видимый фрейм</h>
<t>Создай глобальный фрейм <k>CourseFrameShown</k>.</t>
<t>Требования:</t>
<t>- тип фрейма: <s>"Frame"</s>;</t>
<t>- глобальное имя: <s>"CourseFrameShown"</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 180 на 120;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- фрейм должен быть показан через <k>Show()</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseFrameShown
]=],
requireKeywords = {
"CourseFrameShown",
"CreateFrame",
"Frame",
"UIParent",
"SetSize",
"SetPoint",
"Show",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseFrameShown
if not f or type(f.IsShown) ~= "function" then
_G.checkError = "CourseFrameShown не является фреймом"
return false
end
if not f:IsShown() then
_G.checkError = "Фрейм должен быть показан"
return false
end
if f:GetWidth() ~= 180 then
_G.checkError = "Ширина фрейма должна быть 180"
return false
end
if f:GetHeight() ~= 120 then
_G.checkError = "Высота фрейма должна быть 120"
return false
end
return true
end,
}

ns_llua['lua'][218] = {
type = "commenttest",
title = "Тест 215-3: скрытый фрейм",
helpModules = {215},
preloadVars = {
{var = "CourseFrameHidden", desc = "CourseFrameHidden очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 215-3: скрытый фрейм</h>
<t>Создай глобальный фрейм <k>CourseFrameHidden</k>.</t>
<t>Требования:</t>
<t>- тип фрейма: <s>"Frame"</s>;</t>
<t>- глобальное имя: <s>"CourseFrameHidden"</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 100 на 100;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- фрейм должен быть скрыт через <k>Hide()</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseFrameHidden
]=],
requireKeywords = {
"CourseFrameHidden",
"CreateFrame",
"Frame",
"UIParent",
"SetSize",
"SetPoint",
"Hide",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseFrameHidden
if not f or type(f.IsShown) ~= "function" then
_G.checkError = "CourseFrameHidden не является фреймом"
return false
end
if f:IsShown() then
_G.checkError = "Фрейм должен быть скрыт"
return false
end
return true
end,
}

ns_llua['lua'][219] = {
type = "commenttest",
title = "Тест 215-4: функция IsFrameShownSafe",
helpModules = {215, 45, 65},
preloadVars = {
{var = "IsFrameShownSafe", desc = "IsFrameShownSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 215-4: функция IsFrameShownSafe</h>
<t>Создай глобальную функцию <k>IsFrameShownSafe(frame)</k>.</t>
<t>Если <k>frame</k> не существует или у него нет метода <k>IsShown</k>, функция должна вернуть <k>false</k>.</t>
<t>Иначе функция должна вернуть результат:</t>
<code>
frame:IsShown()
</code>
<t>Результат должен быть именно boolean: <k>true</k> или <k>false</k>.</t>
<t>Используй приведение через <k>and true or false</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию IsFrameShownSafe(frame)
]=],
requireKeywords = {
"IsFrameShownSafe",
"function",
"IsShown",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.IsFrameShownSafe) ~= "function" then
_G.checkError = "IsFrameShownSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.IsFrameShownSafe, UIParent)
if not ok1 or result1 ~= true then
_G.checkError = "Для UIParent функция должна вернуть true"
return false
end
local ok2, result2 = pcall(_G.IsFrameShownSafe, nil)
if not ok2 or result2 ~= false then
_G.checkError = "Для nil функция должна вернуть false"
return false
end
local ok3, result3 = pcall(_G.IsFrameShownSafe, {})
if not ok3 or result3 ~= false then
_G.checkError = "Для пустой таблицы функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][220] = {
type = "commenttest",
title = "Тест 215-5: функция GetFrameNameSafe",
helpModules = {215, 45, 65},
preloadVars = {
{var = "GetFrameNameSafe", desc = "GetFrameNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 215-5: функция GetFrameNameSafe</h>
<t>Создай глобальную функцию <k>GetFrameNameSafe(frame)</k>.</t>
<t>Если <k>frame</k> не существует или у него нет метода <k>GetName</k>, функция должна вернуть строку:</t>
<s>"anonymous"</s>
<t>Иначе функция должна получить имя через:</t>
<code>
frame:GetName()
</code>
<t>Если имя не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"anonymous"</s>
<t>Иначе функция должна вернуть имя фрейма.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetFrameNameSafe(frame)
]=],
requireKeywords = {
"GetFrameNameSafe",
"function",
"GetName",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetFrameNameSafe) ~= "function" then
_G.checkError = "GetFrameNameSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetFrameNameSafe, UIParent)
if not ok1 then
_G.checkError = "Ошибка вызова GetFrameNameSafe(UIParent): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для UIParent функция должна вернуть строку"
return false
end
local anon = CreateFrame("Frame", nil, UIParent)
local ok2, result2 = pcall(_G.GetFrameNameSafe, anon)
if not ok2 or result2 ~= "anonymous" then
_G.checkError = "Для анонимного фрейма функция должна вернуть 'anonymous'"
return false
end
local ok3, result3 = pcall(_G.GetFrameNameSafe, nil)
if not ok3 or result3 ~= "anonymous" then
_G.checkError = "Для nil функция должна вернуть 'anonymous'"
return false
end
return true
end,
}

ns_llua['lua'][221] = {
type = "info",
title = "Позиция, размер и перетаскивание",
helpModules = {215},
content = [=[
<h>Позиция, размер и перетаскивание</h>
<t>Чтобы фрейм было видно, ему нужны размер и точка крепления.</t>
<h>Размер</h>
<code>
MyFirstFrame:SetSize(220, 140)
</code>
<h>Позиция</h>
<code>
MyFirstFrame:SetPoint("CENTER")
</code>
<t>Более точный вариант:</t>
<code>
MyFirstFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -100)
</code>
<t>Это значит:</t>
<c>TOPLEFT</c> фрейма крепится к <c>TOPLEFT</c> родителя.
Смещение: <n>100</n> вправо и <n>-100</n> вниз.
<h>Слой отображения</h>
<code>
MyFirstFrame:SetFrameStrata("HIGH")
</code>
<t>Возможные значения:</t>
<c>"BACKGROUND"</c>
<c>"LOW"</c>
<c>"MEDIUM"</c>
<c>"HIGH"</c>
<c>"DIALOG"</c>
<c>"TOOLTIP"</c>
<h>Прозрачность и масштаб</h>
<code>
MyFirstFrame:SetAlpha(0.8)
MyFirstFrame:SetScale(1.1)
</code>
<h>Перетаскивание</h>
<code>
MyDragFrame = CreateFrame("Frame", "MyDragFrame", UIParent)
MyDragFrame:SetSize(160, 120)
MyDragFrame:SetPoint("CENTER")
MyDragFrame:EnableMouse(true)
MyDragFrame:SetMovable(true)
MyDragFrame:RegisterForDrag("LeftButton")
MyDragFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
MyDragFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
MyDragFrame:Show()
</code>
<w>Примечание:</w> без текстуры или фона фрейм может быть прозрачным, но он всё равно может ловить мышь, если включён <k>EnableMouse</k>.
]=],
}

ns_llua['lua'][222] = {
type = "commenttest",
title = "Тест 221-1: позиция CENTER",
helpModules = {221},
preloadVars = {
{var = "CoursePositionFrame", desc = "CoursePositionFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 221-1: позиция CENTER</h>
<t>Создай глобальный фрейм <k>CoursePositionFrame</k>.</t>
<t>Требования:</t>
<t>- тип фрейма: <s>"Frame"</s>;</t>
<t>- глобальное имя: <s>"CoursePositionFrame"</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 160 на 120;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CoursePositionFrame
]=],
requireKeywords = {
"CoursePositionFrame",
"CreateFrame",
"Frame",
"UIParent",
"SetSize",
"SetPoint",
"CENTER",
},
checkCode = function()
_G.checkError = nil
local f = _G.CoursePositionFrame
if not f or type(f.GetPoint) ~= "function" then
_G.checkError = "CoursePositionFrame не является фреймом"
return false
end
if f:GetWidth() ~= 160 then
_G.checkError = "Ширина фрейма должна быть 160"
return false
end
if f:GetHeight() ~= 120 then
_G.checkError = "Высота фрейма должна быть 120"
return false
end
local point = f:GetPoint(1)
if point ~= "CENTER" then
_G.checkError = "Фрейм должен быть прикреплён через CENTER"
return false
end
return true
end,
}

ns_llua['lua'][223] = {
type = "commenttest",
title = "Тест 221-2: прозрачность и масштаб",
helpModules = {221},
preloadVars = {
{var = "CourseAlphaFrame", desc = "CourseAlphaFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 221-2: прозрачность и масштаб</h>
<t>Создай глобальный фрейм <k>CourseAlphaFrame</k>.</t>
<t>Требования:</t>
<t>- тип фрейма: <s>"Frame"</s>;</t>
<t>- глобальное имя: <s>"CourseAlphaFrame"</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 100 на 100;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- прозрачность: <k>SetAlpha(0.5)</k>;</t>
<t>- масштаб: <k>SetScale(1)</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseAlphaFrame
]=],
requireKeywords = {
"CourseAlphaFrame",
"CreateFrame",
"Frame",
"UIParent",
"SetSize",
"SetPoint",
"SetAlpha",
"SetScale",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseAlphaFrame
if not f or type(f.GetAlpha) ~= "function" or type(f.GetScale) ~= "function" then
_G.checkError = "CourseAlphaFrame не является фреймом"
return false
end
local alpha = f:GetAlpha()
if type(alpha) ~= "number" or math.abs(alpha - 0.5) > 0.01 then
_G.checkError = "Alpha фрейма должен быть примерно 0.5"
return false
end
local scale = f:GetScale()
if type(scale) ~= "number" or math.abs(scale - 1) > 0.01 then
_G.checkError = "Scale фрейма должен быть примерно 1"
return false
end
return true
end,
}

ns_llua['lua'][224] = {
type = "commenttest",
title = "Тест 221-3: слой HIGH",
helpModules = {221},
preloadVars = {
{var = "CourseStrataFrame", desc = "CourseStrataFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 221-3: слой HIGH</h>
<t>Создай глобальный фрейм <k>CourseStrataFrame</k>.</t>
<t>Требования:</t>
<t>- тип фрейма: <s>"Frame"</s>;</t>
<t>- глобальное имя: <s>"CourseStrataFrame"</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 80 на 80;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- слой: <k>SetFrameStrata("HIGH")</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseStrataFrame
]=],
requireKeywords = {
"CourseStrataFrame",
"CreateFrame",
"Frame",
"UIParent",
"SetSize",
"SetPoint",
"SetFrameStrata",
"HIGH",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseStrataFrame
if not f or type(f.GetFrameStrata) ~= "function" then
_G.checkError = "CourseStrataFrame не является фреймом"
return false
end
if f:GetFrameStrata() ~= "HIGH" then
_G.checkError = "Фрейм должен иметь слой HIGH"
return false
end
return true
end,
}

ns_llua['lua'][225] = {
type = "commenttest",
title = "Тест 221-4: перетаскиваемый фрейм",
helpModules = {221},
preloadVars = {
{var = "CourseDragFrame", desc = "CourseDragFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 221-4: перетаскиваемый фрейм</h>
<t>Создай глобальный фрейм <k>CourseDragFrame</k>.</t>
<t>Требования:</t>
<t>- тип фрейма: <s>"Frame"</s>;</t>
<t>- глобальное имя: <s>"CourseDragFrame"</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 140 на 100;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- включи мышку через <k>EnableMouse(true)</k>;</t>
<t>- сделай фрейм перемещаемым через <k>SetMovable(true)</k>;</t>
<t>- зарегистрируй перетаскивание через <k>RegisterForDrag("LeftButton")</k>;</t>
<t>- назначь скрипт <k>OnDragStart</k>, чтобы он вызывал <k>self:StartMoving()</k>;</t>
<t>- назначь скрипт <k>OnDragStop</k>, чтобы он вызывал <k>self:StopMovingOrSizing()</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseDragFrame
]=],
requireKeywords = {
"CourseDragFrame",
"CreateFrame",
"Frame",
"UIParent",
"SetSize",
"SetPoint",
"EnableMouse",
"SetMovable",
"RegisterForDrag",
"SetScript",
"OnDragStart",
"OnDragStop",
"StartMoving",
"StopMovingOrSizing",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseDragFrame
if not f or type(f.GetScript) ~= "function" then
_G.checkError = "CourseDragFrame не является фреймом"
return false
end
if type(f:GetScript("OnDragStart")) ~= "function" then
_G.checkError = "Фрейм должен иметь обработчик OnDragStart"
return false
end
if type(f:GetScript("OnDragStop")) ~= "function" then
_G.checkError = "Фрейм должен иметь обработчик OnDragStop"
return false
end
return true
end,
}

ns_llua['lua'][226] = {
type = "commenttest",
title = "Тест 221-5: функция SetFrameSizeSafe",
helpModules = {221, 45, 65},
preloadVars = {
{var = "SetFrameSizeSafe", desc = "SetFrameSizeSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 221-5: функция SetFrameSizeSafe</h>
<t>Создай глобальную функцию <k>SetFrameSizeSafe(frame, width, height)</k>.</t>
<t>Если <k>frame</k> не существует или у него нет метода <k>SetSize</k>, функция ничего не должна делать.</t>
<t>Если <k>width</k> или <k>height</k> не являются числами, функция ничего не должна делать.</t>
<t>Если <k>width</k> или <k>height</k> меньше либо равны нулю, функция ничего не должна делать.</t>
<t>Иначе функция должна вызвать:</t>
<code>
frame:SetSize(width, height)
</code>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию SetFrameSizeSafe(frame, width, height)
]=],
requireKeywords = {
"SetFrameSizeSafe",
"function",
"SetSize",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.SetFrameSizeSafe) ~= "function" then
_G.checkError = "SetFrameSizeSafe не является глобальной функцией"
return false
end
local f = CreateFrame("Frame", nil, UIParent)
local ok1 = pcall(_G.SetFrameSizeSafe, f, 123, 45)
if not ok1 then
_G.checkError = "Ошибка вызова SetFrameSizeSafe с корректными данными"
return false
end
if f:GetWidth() ~= 123 or f:GetHeight() ~= 45 then
_G.checkError = "SetFrameSizeSafe должна изменить размер фрейма"
return false
end
local ok2 = pcall(_G.SetFrameSizeSafe, f, -5, 10)
if not ok2 then
_G.checkError = "Ошибка вызова SetFrameSizeSafe с отрицательной шириной"
return false
end
if f:GetWidth() ~= 123 or f:GetHeight() ~= 45 then
_G.checkError = "Некорректные данные не должны менять размер фрейма"
return false
end
local ok3 = pcall(_G.SetFrameSizeSafe, nil, 10, 10)
if not ok3 then
_G.checkError = "SetFrameSizeSafe не должна падать на nil"
return false
end
return true
end,
}

ns_llua['lua'][227] = {
type = "info",
title = "Текстуры и текст на фреймах",
helpModules = {215, 221},
content = [=[
<h>Текстуры и текст на фреймах</h>
<t>Сам по себе фрейм невидим. Чтобы что-то показать на нём, нужны текстуры и текстовые объекты.</t>
<h>CreateTexture</h>
<t>Метод <k>CreateTexture</k> создаёт текстуру внутри фрейма.</t>
<code>
MyIconFrame = CreateFrame("Frame", "MyIconFrame", UIParent)
MyIconFrame:SetSize(64, 64)
MyIconFrame:SetPoint("CENTER")
local tex = MyIconFrame:CreateTexture(nil, "ARTWORK")
tex:SetAllPoints(MyIconFrame)
tex:SetTexture("Interface\\Icons\\Spell_Frost_IceStorm")
</code>
<t>Аргументы <k>CreateTexture</k>:</t>
<c>1</c> — имя текстуры. Обычно <k>nil</k>.
<c>2</c> — слой: <s>BACKGROUND</s>, <s>BORDER</s>, <s>ARTWORK</s>, <s>OVERLAY</s>.
<h>SetAllPoints</h>
<t>Метод <k>SetAllPoints(parent)</k> растягивает текстуру на весь родительский фрейм.</t>
<code>
tex:SetAllPoints(MyIconFrame)
</code>
<t>Это то же самое, что прикрепить текстуру всеми четырьмя углами к фрейму.</t>
<h>CreateFontString</h>
<t>Текст создаётся методом <k>CreateFontString</k>.</t>
<code>
local text = MyIconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("CENTER")
text:SetText("Привет!")
</code>
<t>Третий аргумент — шаблон шрифта:</t>
<c>GameFontNormal</c> — обычный текст.
<c>GameFontNormalLarge</c> — крупный текст.
<c>GameFontHighlight</c> — белый текст.
<c>GameFontRed</c> — красный текст.
<h>Цвет текста</h>
<code>
text:SetTextColor(1, 1, 0, 1)
</code>
<t>Четыре числа: красный, зелёный, синий, прозрачность. Каждое от 0 до 1.</t>
<h>Выравнивание</h>
<code>
text:SetJustifyH("LEFT")
text:SetJustifyH("CENTER")
text:SetJustifyH("RIGHT")
</code>
<h>Размер шрифта</h>
<code>
text:SetFont("Fonts\\FRIZQT__.TTF", 16)
</code>
<t>Первый аргумент — файл шрифта, второй — размер.</t>
<w>Важно:</w> если шрифт не найден, текст может не отобразиться. Поэтому лучше использовать готовые шаблоны вроде <k>GameFontNormal</k>.
<h>Иконки из игры</h>
<t>Пути к иконкам начинаются с <s>Interface\Icons\</s>.</t>
<code>
tex:SetTexture("Interface\\Icons\\Spell_Frost_IceStorm")
tex:SetTexture("Interface\\Icons\\Inv_Sword_04")
</code>
<w>Обрати внимание:</w> в Lua-строке обратный слеш пишется как <k>\\</k>, потому что одинарный слеш имеет специальное значение.
<h>Полный пример</h>
<code>
CourseInfoFrame = CreateFrame("Frame", "CourseInfoFrame", UIParent)
CourseInfoFrame:SetSize(200, 200)
CourseInfoFrame:SetPoint("CENTER")
CourseInfoFrame:SetFrameStrata("HIGH")
local bg = CourseInfoFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(CourseInfoFrame)
bg:SetTexture(0.1, 0.1, 0.1, 0.8)
local icon = CourseInfoFrame:CreateTexture(nil, "ARTWORK")
icon:SetSize(64, 64)
icon:SetPoint("TOP", 0, -10)
icon:SetTexture("Interface\\Icons\\Spell_Frost_IceStorm")
local title = CourseInfoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", icon, "BOTTOM", 0, -10)
title:SetText("Курс Lua")
title:SetTextColor(1, 0.84, 0, 1)
CourseInfoFrame:Show()
</code>
<h>Частые ошибки</h>
<w>Ошибка 1:</w> забыть <k>Show()</k> у фрейма.
<w>Ошибка 2:</w> перепутать слой. Текстура на слое <s>BACKGROUND</s> будет под текстом на слое <s>OVERLAY</s>.
<w>Ошибка 3:</w> написать путь к иконке с одинарными слешами.
<code>
tex:SetTexture("Interface\Icons\Icon")   -- ошибка
tex:SetTexture("Interface\\Icons\\Icon") -- правильно
</code>
]=],
}

ns_llua['lua'][228] = {
type = "commenttest",
title = "Тест 227-1: фрейм с иконкой",
helpModules = {227, 221, 215},
preloadVars = {
{var = "CourseIconFrame", desc = "CourseIconFrame очищается перед проверкой"},
},
reportVars = {"CourseIconFrame"},
instruction = [=[
<h>Тест 227-1: фрейм с иконкой</h>
<t>Создай глобальный фрейм <k>CourseIconFrame</k>.</t>
<t>Требования:</t>
<t>- тип: <s>Frame</s>;</t>
<t>- глобальное имя: <s>CourseIconFrame</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 64 на 64;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- внутри создай текстуру слоем <s>ARTWORK</s>;</t>
<t>- текстура должна быть растянута через <k>SetAllPoints</k>;</t>
<t>- установи текстуре путь: <s>Interface\Icons\Spell_Frost_IceStorm</s>;</t>
<t>- покажи фрейм через <k>Show()</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseIconFrame
]=],
requireKeywords = {
"CourseIconFrame",
"CreateFrame",
"Frame",
"UIParent",
"SetSize",
"SetPoint",
"CreateTexture",
"ARTWORK",
"SetAllPoints",
"SetTexture",
"Show",
},
checkCode = function()
local f = _G.CourseIconFrame
if not f then
    return false
end
if type(f.IsShown) ~= "function" then
    return false
end
if not f:IsShown() then
    return false
end
if f:GetWidth() ~= 64 or f:GetHeight() ~= 64 then
    return false
end
if not f.CreateTexture or type(f.CreateTexture) ~= "function" then
    return false
end
return true
end,
}

ns_llua['lua'][229] = {
type = "commenttest",
title = "Тест 227-2: фрейм с текстом",
helpModules = {227, 215, 7},
preloadVars = {
{var = "CourseTextFrame", desc = "CourseTextFrame очищается перед проверкой"},
},
reportVars = {"CourseTextFrame"},
instruction = [=[
<h>Тест 227-2: фрейм с текстом</h>
<t>Создай глобальный фрейм <k>CourseTextFrame</k>.</t>
<t>Требования:</t>
<t>- тип: <s>Frame</s>;</t>
<t>- глобальное имя: <s>CourseTextFrame</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 200 на 60;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- внутри создай FontString слоем <s>OVERLAY</s> с шаблоном <s>GameFontNormal</s>;</t>
<t>- установи текст: <s>Привет, Азерот!</s>;</t>
<t>- прикрепи текст через <k>SetPoint("CENTER")</k>;</t>
<t>- покажи фрейм через <k>Show()</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseTextFrame
]=],
requireKeywords = {
"CourseTextFrame",
"CreateFrame",
"Frame",
"UIParent",
"SetSize",
"SetPoint",
"CreateFontString",
"OVERLAY",
"GameFontNormal",
"SetText",
"Show",
},
checkCode = function()
local f = _G.CourseTextFrame
if not f then
    return false
end
if type(f.IsShown) ~= "function" then
    return false
end
if not f:IsShown() then
    return false
end
if f:GetWidth() ~= 200 or f:GetHeight() ~= 60 then
    return false
end
if type(f.CreateFontString) ~= "function" then
    return false
end
return true
end,
}

ns_llua['lua'][230] = {
type = "commenttest",
title = "Тест 227-3: функция CreateLabeledFrame",
helpModules = {227, 215, 45, 65},
preloadVars = {
{var = "CreateLabeledFrame", desc = "CreateLabeledFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 227-3: функция CreateLabeledFrame</h>
<t>Создай глобальную функцию <k>CreateLabeledFrame(name, text)</k>.</t>
<t>Функция должна создать фрейм и вернуть его.</t>
<t>Требования:</t>
<t>- если <k>name</k> не строка или пустая строка, функция должна вернуть <k>nil</k>;</t>
<t>- если <k>text</k> не строка, используй пустую строку <s>""</s>;</t>
<t>- создай фрейм типа <s>Frame</s> с именем <k>name</k> и родителем <k>UIParent</k>;</t>
<t>- размер фрейма: 220 на 80;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- создай внутри FontString слоем <s>OVERLAY</s> с шаблоном <s>GameFontNormal</s>;</t>
<t>- установи тексту текст из аргумента;</t>
<t>- прикрепи текст через <k>SetPoint("CENTER")</k>;</t>
<t>- покажи фрейм;</t>
<t>- верни фрейм.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateLabeledFrame(name, text)
]=],
requireKeywords = {
"CreateLabeledFrame",
"function",
"CreateFrame",
"CreateFontString",
"SetText",
"SetPoint",
"Show",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateLabeledFrame) ~= "function" then
    _G.checkError = "CreateLabeledFrame не является глобальной функцией"
    return false
end
local ok1, f1 = pcall(_G.CreateLabeledFrame, "NS_Test_Labeled_1", "Текст")
if not ok1 then
    _G.checkError = "Ошибка вызова CreateLabeledFrame: " .. tostring(f1)
    return false
end
if not f1 or type(f1.IsShown) ~= "function" then
    _G.checkError = "Функция должна вернуть фрейм"
    return false
end
if not f1:IsShown() then
    _G.checkError = "Фрейм должен быть показан"
    return false
end
if f1:GetWidth() ~= 220 or f1:GetHeight() ~= 80 then
    _G.checkError = "Размер фрейма должен быть 220 на 80"
    return false
end
local ok2, f2 = pcall(_G.CreateLabeledFrame, "", "Текст")
if not ok2 or f2 ~= nil then
    _G.checkError = "Для пустого имени функция должна вернуть nil"
    return false
end
local ok3, f3 = pcall(_G.CreateLabeledFrame, 123, "Текст")
if not ok3 or f3 ~= nil then
    _G.checkError = "Для нестрокового имени функция должна вернуть nil"
    return false
end
local ok4, f4 = pcall(_G.CreateLabeledFrame, "NS_Test_Labeled_2", nil)
if not ok4 then
    _G.checkError = "Ошибка вызова CreateLabeledFrame с nil-текстом: " .. tostring(f4)
    return false
end
if not f4 or type(f4.IsShown) ~= "function" then
    _G.checkError = "Для nil-текста функция всё равно должна вернуть фрейм"
    return false
end
return true
end,
}

ns_llua['lua'][231] = {
type = "commenttest",
title = "Тест 227-4: функция SetFrameTextSafe",
helpModules = {227, 215, 45, 65, 21},
preloadVars = {
{var = "SetFrameTextSafe", desc = "SetFrameTextSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 227-4: функция SetFrameTextSafe</h>
<t>Создай глобальную функцию <k>SetFrameTextSafe(frame, text)</k>.</t>
<t>Функция должна безопасно установить текст на фрейм.</t>
<t>Требования:</t>
<t>- если <k>frame</k> не существует или у него нет метода <k>CreateFontString</k>, функция должна вернуть <k>false</k>;</t>
<t>- если <k>text</k> не строка, функция должна вернуть <k>false</k>;</t>
<t>- иначе создай FontString слоем <s>OVERLAY</s> с шаблоном <s>GameFontNormal</s>;</t>
<t>- прикрепи текст через <k>SetPoint("CENTER")</k>;</t>
<t>- установи текст через <k>SetText(text)</k>;</t>
<t>- верни <k>true</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию SetFrameTextSafe(frame, text)
]=],
requireKeywords = {
"SetFrameTextSafe",
"function",
"CreateFontString",
"OVERLAY",
"GameFontNormal",
"SetText",
"SetPoint",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.SetFrameTextSafe) ~= "function" then
    _G.checkError = "SetFrameTextSafe не является глобальной функцией"
    return false
end
local testFrame = CreateFrame("Frame", nil, UIParent)
testFrame:SetSize(150, 50)
local ok1, result1 = pcall(_G.SetFrameTextSafe, testFrame, "Проверка")
if not ok1 then
    _G.checkError = "Ошибка вызова SetFrameTextSafe: " .. tostring(result1)
    return false
end
if result1 ~= true then
    _G.checkError = "Для корректного фрейма функция должна вернуть true"
    return false
end
local ok2, result2 = pcall(_G.SetFrameTextSafe, nil, "Проверка")
if not ok2 or result2 ~= false then
    _G.checkError = "Для nil-фрейма функция должна вернуть false"
    return false
end
local ok3, result3 = pcall(_G.SetFrameTextSafe, testFrame, 123)
if not ok3 or result3 ~= false then
    _G.checkError = "Для нестрокового текста функция должна вернуть false"
    return false
end
local ok4, result4 = pcall(_G.SetFrameTextSafe, {}, "Проверка")
if not ok4 or result4 ~= false then
    _G.checkError = "Для пустой таблицы функция должна вернуть false"
    return false
end
return true
end,
}

ns_llua['lua'][232] = {
type = "commenttest",
title = "Тест 227-5: функция CreateIconFrameSafe",
helpModules = {227, 221, 215, 45, 65, 10, 17, 19},
preloadVars = {
{var = "CreateIconFrameSafe", desc = "CreateIconFrameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 227-5: функция CreateIconFrameSafe</h>
<t>Создай глобальную функцию <k>CreateIconFrameSafe(parent, texturePath, size)</k>.</t>
<t>Функция должна безопасно создать фрейм с иконкой.</t>
<t>Требования:</t>
<t>- если <k>parent</k> не существует или у него нет метода <k>CreateFrame</k> как у фрейма, верни <k>nil</k>;</t>
<t>- если <k>texturePath</k> не строка или пустая строка, верни <k>nil</k>;</t>
<t>- если <k>size</k> не число, меньше 8 или больше 512, верни <k>nil</k>;</t>
<t>- иначе создай анонимный фрейм типа <s>Frame</s> с родителем <k>parent</k>;</t>
<t>- размер фрейма: <k>size</k> на <k>size</k>;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- создай текстуру слоем <s>ARTWORK</s>;</t>
<t>- растяни текстуру через <k>SetAllPoints</k>;</t>
<t>- установи текстуру через <k>SetTexture(texturePath)</k>;</t>
<t>- покажи фрейм;</t>
<t>- верни фрейм.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateIconFrameSafe(parent, texturePath, size)
]=],
requireKeywords = {
"CreateIconFrameSafe",
"function",
"CreateFrame",
"CreateTexture",
"SetAllPoints",
"SetTexture",
"SetSize",
"SetPoint",
"Show",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateIconFrameSafe) ~= "function" then
    _G.checkError = "CreateIconFrameSafe не является глобальной функцией"
    return false
end
local ok1, f1 = pcall(_G.CreateIconFrameSafe, UIParent, "Interface\\Icons\\Spell_Frost_IceStorm", 48)
if not ok1 then
    _G.checkError = "Ошибка вызова CreateIconFrameSafe: " .. tostring(f1)
    return false
end
if not f1 or type(f1.IsShown) ~= "function" then
    _G.checkError = "Для корректных данных функция должна вернуть фрейм"
    return false
end
if not f1:IsShown() then
    _G.checkError = "Созданный фрейм должен быть показан"
    return false
end
if f1:GetWidth() ~= 48 or f1:GetHeight() ~= 48 then
    _G.checkError = "Размер фрейма должен совпадать с аргументом size"
    return false
end
local ok2, f2 = pcall(_G.CreateIconFrameSafe, nil, "Interface\\Icons\\Spell_Frost_IceStorm", 48)
if not ok2 or f2 ~= nil then
    _G.checkError = "Для nil-родителя функция должна вернуть nil"
    return false
end
local ok3, f3 = pcall(_G.CreateIconFrameSafe, UIParent, "", 48)
if not ok3 or f3 ~= nil then
    _G.checkError = "Для пустой строки текстуры функция должна вернуть nil"
    return false
end
local ok4, f4 = pcall(_G.CreateIconFrameSafe, UIParent, "Interface\\Icons\\Spell_Frost_IceStorm", 4)
if not ok4 or f4 ~= nil then
    _G.checkError = "Для размера меньше 8 функция должна вернуть nil"
    return false
end
local ok5, f5 = pcall(_G.CreateIconFrameSafe, UIParent, "Interface\\Icons\\Spell_Frost_IceStorm", 1000)
if not ok5 or f5 ~= nil then
    _G.checkError = "Для размера больше 512 функция должна вернуть nil"
    return false
end
local ok6, f6 = pcall(_G.CreateIconFrameSafe, UIParent, "Interface\\Icons\\Spell_Frost_IceStorm", "big")
if not ok6 or f6 ~= nil then
    _G.checkError = "Для нечислового размера функция должна вернуть nil"
    return false
end
return true
end,
}






























ns_llua['lua'][233] = {
type = "info",
title = "Кнопки и обработчики кликов",
helpModules = {215, 221, 227},
content = [=[
<h>Кнопки и обработчики кликов</h>
<t>Кнопка — это специальный тип фрейма, который реагирует на клики мыши.</t>
<h>Создание кнопки</h>
<code>
CourseButton = CreateFrame("Button", "CourseButton", UIParent)
CourseButton:SetSize(120, 40)
CourseButton:SetPoint("CENTER")
</code>
<t>Обрати внимание: тип фрейма — <s>"Button"</s>, а не <s>"Frame"</s>.</t>
<h>Текст кнопки через FontString</h>
<t>У кнопки без шаблона нет встроенного текста. Его нужно создавать вручную:</t>
<code>
local fs = CourseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fs:SetAllPoints(CourseButton)
fs:SetText("Нажми меня")
</code>
<h>Шаблон UIPanelButtonTemplate</h>
<t>WoW предоставляет готовые шаблоны. С шаблоном <s>"UIPanelButtonTemplate"</s> кнопка получает стандартный внешний вид и метод <k>SetText</k>:</t>
<code>
CourseStyledButton = CreateFrame("Button", "CourseStyledButton", UIParent, "UIPanelButtonTemplate")
CourseStyledButton:SetSize(120, 40)
CourseStyledButton:SetPoint("CENTER")
CourseStyledButton:SetText("Готово")
</code>
<w>Примечание:</w> в WoW 3.3.5 <k>SetText</k> работает для кнопок, созданных с шаблоном <s>"UIPanelButtonTemplate"</s>. Для кнопок без шаблона нужно создавать FontString вручную.
<h>Обработчик клика</h>
<code>
CourseButton:SetScript("OnClick", function(self, button)
    print("Клик! Кнопка мыши: " .. tostring(button))
end)
</code>
<t>Аргументы обработчика:</t>
<c>self</c> — сама кнопка.
<c>button</c> — какая кнопка мыши нажата: <s>"LeftButton"</s>, <s>"RightButton"</s> и т.д.
<h>Enable и Disable</h>
<code>
CourseButton:Enable()
CourseButton:Disable()
</code>
<t>Отключённая кнопка не реагирует на клики.</t>
<h>Проверка состояния</h>
<code>
if CourseButton:IsEnabled() then
    print("Кнопка включена")
else
    print("Кнопка отключена")
end
</code>
<w>Важно:</w> в WoW 3.3.5 <k>IsEnabled()</k> возвращает <k>1</k> или <k>nil</k>, а не <k>true</k>/<k>false</k>. Но в условии <k>if</k> это работает одинаково, потому что <k>1</k> — истина, а <k>nil</k> — ложь.
<h>Безопасный обработчик</h>
<code>
CourseSafeButton:SetScript("OnClick", function(self)
    if not self:IsEnabled() then return end
    print("Действие выполнено")
end)
</code>
<h>Частые ошибки</h>
<w>Ошибка 1:</w> забыть <k>Show()</k> у кнопки.
<w>Ошибка 2:</w> использовать <k>SetText</k> на кнопке без шаблона.
<w>Ошибка 3:</w> сравнивать <k>IsEnabled()</k> с <k>true</k> через <k>==</k>.
<code>
-- неправильно
if CourseButton:IsEnabled() == true then
-- правильно
if CourseButton:IsEnabled() then
</code>
]=],
}

ns_llua['lua'][234] = {
type = "commenttest",
title = "Тест 233-1: кнопка с обработчиком",
helpModules = {233, 215, 221},
preloadVars = {
{var = "CourseClickButton", desc = "CourseClickButton очищается перед проверкой"},
{var = "courseClickCount", desc = "courseClickCount очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
"courseClickCount",
},
instruction = [=[
<h>Тест 233-1: кнопка с обработчиком</h>
<t>Создай глобальную кнопку <k>CourseClickButton</k>.</t>
<t>Требования:</t>
<t>- тип фрейма: <s>"Button"</s>;</t>
<t>- глобальное имя: <s>"CourseClickButton"</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 120 на 40;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- создай глобальную переменную <k>courseClickCount</k> со значением <n>0</n>;</t>
<t>- назначь обработчик <k>OnClick</k>, который увеличивает <k>courseClickCount</k> на 1.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную кнопку CourseClickButton
]=],
requireKeywords = {
"CourseClickButton",
"CreateFrame",
"Button",
"UIParent",
"SetSize",
"SetPoint",
"SetScript",
"OnClick",
"courseClickCount",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseClickButton
if not f then
    _G.checkError = "CourseClickButton не был создан"
    return false
end
if type(f.GetScript) ~= "function" then
    _G.checkError = "CourseClickButton не похож на кнопку"
    return false
end
if f:GetWidth() ~= 120 or f:GetHeight() ~= 40 then
    _G.checkError = "Размер кнопки должен быть 120 на 40"
    return false
end
local script = f:GetScript("OnClick")
if type(script) ~= "function" then
    _G.checkError = "У кнопки должен быть обработчик OnClick"
    return false
end
if _G.courseClickCount ~= 0 then
    _G.checkError = "courseClickCount должен быть 0 до клика"
    return false
end
-- Вызываем обработчик вручную, чтобы проверить логику
local ok, err = pcall(script, f, "LeftButton")
if not ok then
    _G.checkError = "Ошибка при вызове OnClick: " .. tostring(err)
    return false
end
if _G.courseClickCount ~= 1 then
    _G.checkError = "После одного клика courseClickCount должен быть 1"
    return false
end
-- Второй клик
local ok2, err2 = pcall(script, f, "LeftButton")
if not ok2 then
    _G.checkError = "Ошибка при втором вызове OnClick: " .. tostring(err2)
    return false
end
if _G.courseClickCount ~= 2 then
    _G.checkError = "После двух кликов courseClickCount должен быть 2"
    return false
end
return true
end,
}

ns_llua['lua'][235] = {
type = "commenttest",
title = "Тест 233-2: кнопка-переключатель",
helpModules = {233, 215, 221, 17},
preloadVars = {
{var = "CourseToggleTarget", desc = "CourseToggleTarget очищается перед проверкой"},
{var = "CourseToggleButton", desc = "CourseToggleButton очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 233-2: кнопка-переключатель</h>
<t>Создай два глобальных объекта:</t>
<t>1. Фрейм <k>CourseToggleTarget</k>:</t>
<t>- тип: <s>"Frame"</s>, родитель: <k>UIParent</k>;</t>
<t>- размер: 100 на 100;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- фрейм должен быть показан через <k>Show()</k>.</t>
<t>2. Кнопку <k>CourseToggleButton</k>:</t>
<t>- тип: <s>"Button"</s>, родитель: <k>UIParent</k>;</t>
<t>- размер: 100 на 30;</t>
<t>- позиция: <k>SetPoint("CENTER", UIParent, "CENTER", 0, -100)</k>;</t>
<t>- обработчик <k>OnClick</k>, который переключает видимость <k>CourseToggleTarget</k>:</t>
<t>если фрейм показан — скрыть через <k>Hide()</k>, иначе — показать через <k>Show()</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай CourseToggleTarget и CourseToggleButton
]=],
requireKeywords = {
"CourseToggleTarget",
"CourseToggleButton",
"CreateFrame",
"Frame",
"Button",
"UIParent",
"SetSize",
"SetPoint",
"Show",
"SetScript",
"OnClick",
"IsShown",
"Hide",
},
checkCode = function()
_G.checkError = nil
local target = _G.CourseToggleTarget
local button = _G.CourseToggleButton
if not target then
    _G.checkError = "CourseToggleTarget не был создан"
    return false
end
if not button then
    _G.checkError = "CourseToggleButton не был создан"
    return false
end
if type(target.IsShown) ~= "function" then
    _G.checkError = "CourseToggleTarget не похож на фрейм"
    return false
end
if type(button.GetScript) ~= "function" then
    _G.checkError = "CourseToggleButton не похож на кнопку"
    return false
end
if not target:IsShown() then
    _G.checkError = "CourseToggleTarget должен быть показан изначально"
    return false
end
local script = button:GetScript("OnClick")
if type(script) ~= "function" then
    _G.checkError = "У кнопки должен быть обработчик OnClick"
    return false
end
-- Первый клик: фрейм должен скрыться
local ok1, err1 = pcall(script, button, "LeftButton")
if not ok1 then
    _G.checkError = "Ошибка при первом вызове OnClick: " .. tostring(err1)
    return false
end
if target:IsShown() then
    _G.checkError = "После первого клика фрейм должен быть скрыт"
    return false
end
-- Второй клик: фрейм должен показаться
local ok2, err2 = pcall(script, button, "LeftButton")
if not ok2 then
    _G.checkError = "Ошибка при втором вызове OnClick: " .. tostring(err2)
    return false
end
if not target:IsShown() then
    _G.checkError = "После второго клика фрейм должен быть показан"
    return false
end
return true
end,
}

ns_llua['lua'][236] = {
type = "commenttest",
title = "Тест 233-3: функция CreateClickCounter",
helpModules = {233, 215, 45, 44},
preloadVars = {
{var = "CreateClickCounter", desc = "CreateClickCounter очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 233-3: функция CreateClickCounter</h>
<t>Создай глобальную функцию <k>CreateClickCounter(name)</k>.</t>
<t>Аргумент:</t>
<c>name</c> — строка с глобальным именем кнопки.
<t>Функция должна:</t>
<t>- если <k>name</k> не является строкой или является пустой строкой, вернуть <k>nil</k>;</t>
<t>- создать кнопку типа <s>"Button"</s> с глобальным именем <k>name</k> и родителем <k>UIParent</k>;</t>
<t>- задать размер 100 на 30;</t>
<t>- задать позицию <k>SetPoint("CENTER")</k>;</t>
<t>- создать таблицу-счётчик с полем <k>count</k> равным <n>0</n>;</t>
<t>- назначить обработчик <k>OnClick</k>, который увеличивает <k>count</k> на 1;</t>
<t>- вернуть таблицу с полями:</t>
<c>frame</c> — созданная кнопка.
<c>count</c> — текущее количество кликов.
<c>GetCount</c> — функция, которая возвращает текущее количество кликов.
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateClickCounter(name)
]=],
requireKeywords = {
"CreateClickCounter",
"function",
"CreateFrame",
"Button",
"SetScript",
"OnClick",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateClickCounter) ~= "function" then
    _G.checkError = "CreateClickCounter не является глобальной функцией"
    return false
end
local ok1, result1 = pcall(_G.CreateClickCounter, "NS_Test_Counter_1")
if not ok1 then
    _G.checkError = "Ошибка вызова CreateClickCounter: " .. tostring(result1)
    return false
end
if type(result1) ~= "table" then
    _G.checkError = "Функция должна вернуть таблицу"
    return false
end
if result1.count ~= 0 then
    _G.checkError = "Начальное значение count должно быть 0"
    return false
end
if not result1.frame then
    _G.checkError = "В таблице должно быть поле frame"
    return false
end
if type(result1.GetCount) ~= "function" then
    _G.checkError = "В таблице должна быть функция GetCount"
    return false
end
if result1.GetCount() ~= 0 then
    _G.checkError = "GetCount должна вернуть 0 до кликов"
    return false
end
-- Вызываем OnClick вручную
local script = result1.frame:GetScript("OnClick")
if type(script) ~= "function" then
    _G.checkError = "У кнопки должен быть обработчик OnClick"
    return false
end
local ok2, err2 = pcall(script, result1.frame, "LeftButton")
if not ok2 then
    _G.checkError = "Ошибка при вызове OnClick: " .. tostring(err2)
    return false
end
if result1.count ~= 1 then
    _G.checkError = "После одного клика count должен быть 1"
    return false
end
if result1.GetCount() ~= 1 then
    _G.checkError = "GetCount должна вернуть 1 после одного клика"
    return false
end
-- Проверяем пустое имя
local ok3, result3 = pcall(_G.CreateClickCounter, "")
if not ok3 or result3 ~= nil then
    _G.checkError = "Для пустого имени функция должна вернуть nil"
    return false
end
-- Проверяем нестроковое имя
local ok4, result4 = pcall(_G.CreateClickCounter, 123)
if not ok4 or result4 ~= nil then
    _G.checkError = "Для нестрокового имени функция должна вернуть nil"
    return false
end
return true
end,
}

ns_llua['lua'][237] = {
type = "commenttest",
title = "Тест 233-4: функция SetButtonEnabledSafe",
helpModules = {233, 45, 65, 21},
preloadVars = {
{var = "SetButtonEnabledSafe", desc = "SetButtonEnabledSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 233-4: функция SetButtonEnabledSafe</h>
<t>Создай глобальную функцию <k>SetButtonEnabledSafe(button, enabled)</k>.</t>
<t>Функция должна безопасно включить или выключить кнопку.</t>
<t>Требования:</t>
<t>- если <k>button</k> не существует или у него нет метода <k>Enable</k> или <k>Disable</k>, функция должна вернуть <k>false</k>;</t>
<t>- если <k>enabled</k> является истинным значением, вызови <k>button:Enable()</k> и верни <k>true</k>;</t>
<t>- если <k>enabled</k> является ложным значением, вызови <k>button:Disable()</k> и верни <k>true</k>;</t>
<t>- используй <k>type</k> для проверки наличия методов.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию SetButtonEnabledSafe(button, enabled)
]=],
requireKeywords = {
"SetButtonEnabledSafe",
"function",
"Enable",
"Disable",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.SetButtonEnabledSafe) ~= "function" then
    _G.checkError = "SetButtonEnabledSafe не является глобальной функцией"
    return false
end
-- Создаём тестовую кнопку
local testButton = CreateFrame("Button", nil, UIParent)
testButton:SetSize(80, 30)
-- Тест 1: выключить кнопку
local ok1, result1 = pcall(_G.SetButtonEnabledSafe, testButton, false)
if not ok1 then
    _G.checkError = "Ошибка вызова SetButtonEnabledSafe(button, false): " .. tostring(result1)
    return false
end
if result1 ~= true then
    _G.checkError = "Для корректной кнопки и false функция должна вернуть true"
    return false
end
if testButton:IsEnabled() then
    _G.checkError = "После Disable кнопка должна быть отключена"
    return false
end
-- Тест 2: включить кнопку
local ok2, result2 = pcall(_G.SetButtonEnabledSafe, testButton, true)
if not ok2 then
    _G.checkError = "Ошибка вызова SetButtonEnabledSafe(button, true): " .. tostring(result2)
    return false
end
if result2 ~= true then
    _G.checkError = "Для корректной кнопки и true функция должна вернуть true"
    return false
end
if not testButton:IsEnabled() then
    _G.checkError = "После Enable кнопка должна быть включена"
    return false
end
-- Тест 3: nil вместо кнопки
local ok3, result3 = pcall(_G.SetButtonEnabledSafe, nil, true)
if not ok3 or result3 ~= false then
    _G.checkError = "Для nil-кнопки функция должна вернуть false"
    return false
end
-- Тест 4: пустая таблица вместо кнопки
local ok4, result4 = pcall(_G.SetButtonEnabledSafe, {}, true)
if not ok4 or result4 ~= false then
    _G.checkError = "Для пустой таблицы функция должна вернуть false"
    return false
end
return true
end,
}

ns_llua['lua'][238] = {
type = "commenttest",
title = "Тест 233-5: функция ToggleFrameVisibility",
helpModules = {233, 215, 45, 65, 17},
preloadVars = {
{var = "ToggleFrameVisibility", desc = "ToggleFrameVisibility очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 233-5: функция ToggleFrameVisibility</h>
<t>Создай глобальную функцию <k>ToggleFrameVisibility(frame)</k>.</t>
<t>Функция должна переключить видимость фрейма.</t>
<t>Требования:</t>
<t>- если <k>frame</k> не существует или у него нет метода <k>IsShown</k>, функция должна вернуть <k>nil</k>;</t>
<t>- если фрейм показан, вызови <k>frame:Hide()</k> и верни <k>false</k>;</t>
<t>- если фрейм скрыт, вызови <k>frame:Show()</k> и верни <k>true</k>;</t>
<t>- используй <k>IsShown()</k> для проверки видимости.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию ToggleFrameVisibility(frame)
]=],
requireKeywords = {
"ToggleFrameVisibility",
"function",
"IsShown",
"Show",
"Hide",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.ToggleFrameVisibility) ~= "function" then
    _G.checkError = "ToggleFrameVisibility не является глобальной функцией"
    return false
end
-- Создаём тестовый фрейм
local testFrame = CreateFrame("Frame", nil, UIParent)
testFrame:SetSize(100, 100)
testFrame:SetPoint("CENTER")
testFrame:Show()
-- Тест 1: фрейм показан -> должен скрыться
local ok1, result1 = pcall(_G.ToggleFrameVisibility, testFrame)
if not ok1 then
    _G.checkError = "Ошибка вызова ToggleFrameVisibility: " .. tostring(result1)
    return false
end
if result1 ~= false then
    _G.checkError = "Для показанного фрейма функция должна вернуть false"
    return false
end
if testFrame:IsShown() then
    _G.checkError = "После ToggleFrameVisibility показанный фрейм должен быть скрыт"
    return false
end
-- Тест 2: фрейм скрыт -> должен показаться
local ok2, result2 = pcall(_G.ToggleFrameVisibility, testFrame)
if not ok2 then
    _G.checkError = "Ошибка второго вызова ToggleFrameVisibility: " .. tostring(result2)
    return false
end
if result2 ~= true then
    _G.checkError = "Для скрытого фрейма функция должна вернуть true"
    return false
end
if not testFrame:IsShown() then
    _G.checkError = "После ToggleFrameVisibility скрытый фрейм должен быть показан"
    return false
end
-- Тест 3: nil вместо фрейма
local ok3, result3 = pcall(_G.ToggleFrameVisibility, nil)
if not ok3 or result3 ~= nil then
    _G.checkError = "Для nil-фрейма функция должна вернуть nil"
    return false
end
-- Тест 4: пустая таблица вместо фрейма
local ok4, result4 = pcall(_G.ToggleFrameVisibility, {})
if not ok4 or result4 ~= nil then
    _G.checkError = "Для пустой таблицы функция должна вернуть nil"
    return false
end
return true
end,
}

ns_llua['lua'][239] = {
type = "info",
title = "События: RegisterEvent и OnEvent",
helpModules = {215, 227, 233},
content = [=[
<h>События: RegisterEvent и OnEvent</h>
<t>До сих пор наш код выполнялся один раз. Чтобы аддон реагировал на действия игрока — смену цели, получение урона, вход в игру — нужны события.</t>
<h>Как работают события</h>
<t>WoW генерирует события автоматически. Например:</t>
<c>PLAYER_LOGIN</c> — игрок вошёл в мир.
<c>PLAYER_TARGET_CHANGED</c> — сменилась цель.
<c>UNIT_HEALTH</c> — изменилось здоровье юнита.
<c>PLAYER_REGEN_ENABLED</c> — игрок вышел из боя.
<c>PLAYER_REGEN_DISABLED</c> — игрок вошёл в бой.
<c>BAG_UPDATE</c> — содержимое сумок изменилось.
<h>Регистрация события</h>
<t>Чтобы фрейм получал события, нужно зарегистрировать их методом <k>RegisterEvent</k>:</t>
<code>
MyEventFrame = CreateFrame("Frame", nil, UIParent)
MyEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
</code>
<h>Обработчик OnEvent</h>
<t>Когда событие происходит, WoW вызывает скрипт <k>OnEvent</k>:</t>
<code>
MyEventFrame:SetScript("OnEvent", function(self, event)
    print("Событие: " .. event)
end)
</code>
<t>Аргументы обработчика:</t>
<c>self</c> — фрейм, на который пришло событие.
<c>event</c> — строка с именем события.
<c>...</c> — дополнительные аргументы события (зависят от события).
<h>Несколько событий на одном фрейме</h>
<code>
MyMultiFrame = CreateFrame("Frame", nil, UIParent)
MyMultiFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
MyMultiFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
MyMultiFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        print("Цель изменилась")
    elseif event == "PLAYER_REGEN_DISABLED" then
        print("Вошёл в бой")
    end
end)
</code>
<h>Событие UNIT_HEALTH</h>
<t>Некоторые события требуют указания юнита через <k>RegisterUnitEvent</k>:</t>
<code>
MyHealthFrame = CreateFrame("Frame", nil, UIParent)
MyHealthFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
MyHealthFrame:SetScript("OnEvent", function(self, event, unit)
    if unit == "player" then
        print("HP: " .. (UnitHealth("player") or 0))
    end
end)
</code>
<w>Важно:</w> в WoW 3.3.5 вместо RegisterUnitEvent можно использовать RegisterEvent, но тогда придётся вручную проверять аргумент unit.
<h>PLAYER_LOGIN — точка входа</h>
<t>Событие <c>PLAYER_LOGIN</c> срабатывает, когда игрок полностью вошёл в мир. Это лучшее место для инициализации аддона:</t>
<code>
MyInitFrame = CreateFrame("Frame", nil, UIParent)
MyInitFrame:RegisterEvent("PLAYER_LOGIN")
MyInitFrame:SetScript("OnEvent", function(self, event)
    print("Добро пожаловать, " .. (UnitName("player") or "Неизвестный"))
end)
</code>
<h>Частые ошибки</h>
<w>Ошибка 1:</w> забыть зарегистрировать событие перед назначением OnEvent.
<code>
-- неправильно: событие не зарегистрировано
MyFrame:SetScript("OnEvent", function(self, event) end)
-- правильно: сначала регистрируем
MyFrame:RegisterEvent("PLAYER_LOGIN")
MyFrame:SetScript("OnEvent", function(self, event) end)
</code>
<w>Ошибка 2:</w> сравнивать event с числом вместо строки.
<code>
-- неправильно
if event == 1 then
-- правильно
if event == "PLAYER_TARGET_CHANGED" then
</code>
<w>Ошибка 3:</w> ожидать, что OnEvent вызовется без RegisterEvent. Событие придёт только на зарегистрированные события.
]=],
}

ns_llua['lua'][240] = {
type = "vartest",
title = "Тест 239-1: строки событий",
helpModules = {239},
tasks = {
{
var = "eventLogin",
desc = 'Создай глобальную переменную eventLogin = "PLAYER_LOGIN"',
check = function(value)
return value == "PLAYER_LOGIN"
end,
},
{
var = "eventTarget",
desc = 'Создай глобальную переменную eventTarget = "PLAYER_TARGET_CHANGED"',
check = function(value)
return value == "PLAYER_TARGET_CHANGED"
end,
},
{
var = "eventCombatStart",
desc = 'Создай глобальную переменную eventCombatStart = "PLAYER_REGEN_DISABLED"',
check = function(value)
return value == "PLAYER_REGEN_DISABLED"
end,
},
},
}

ns_llua['lua'][241] = {
type = "commenttest",
title = "Тест 239-2: фрейм с зарегистрированным событием",
helpModules = {239, 215},
preloadVars = {
{var = "CourseEventFrame", desc = "CourseEventFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 239-2: фрейм с зарегистрированным событием</h>
<t>Создай глобальный фрейм <k>CourseEventFrame</k>.</t>
<t>Требования:</t>
<t>- тип: <s>"Frame"</s>, родитель: <k>UIParent</k>;</t>
<t>- зарегистрируй событие <s>"PLAYER_TARGET_CHANGED"</s> через <k>RegisterEvent</k>;</t>
<t>- назначь скрипт <k>OnEvent</k>, который ничего не делает (пустая функция).</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseEventFrame
]=],
requireKeywords = {
"CourseEventFrame",
"CreateFrame",
"Frame",
"UIParent",
"RegisterEvent",
"PLAYER_TARGET_CHANGED",
"SetScript",
"OnEvent",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseEventFrame
if not f then
    _G.checkError = "CourseEventFrame не был создан"
    return false
end
if type(f.GetScript) ~= "function" then
    _G.checkError = "CourseEventFrame не похож на фрейм"
    return false
end
local script = f:GetScript("OnEvent")
if type(script) ~= "function" then
    _G.checkError = "У фрейма должен быть обработчик OnEvent"
    return false
end
if type(f.RegisterEvent) ~= "function" then
    _G.checkError = "У фрейма должен быть метод RegisterEvent"
    return false
end
return true
end,
}

ns_llua['lua'][242] = {
type = "commenttest",
title = "Тест 239-3: обработчик с двумя событиями",
helpModules = {239, 215, 19},
preloadVars = {
{var = "CourseMultiEventFrame", desc = "CourseMultiEventFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 239-3: обработчик с двумя событиями</h>
<t>Создай глобальный фрейм <k>CourseMultiEventFrame</k>.</t>
<t>Требования:</t>
<t>- тип: <s>"Frame"</s>, родитель: <k>UIParent</k>;</t>
<t>- зарегистрируй два события:</t>
<c>"PLAYER_REGEN_DISABLED"</c>
<c>"PLAYER_REGEN_ENABLED"</c>
<t>- назначь скрипт <k>OnEvent</k>, который:</t>
<t>если event равен <s>"PLAYER_REGEN_DISABLED"</s>, записывает в глобальную переменную <k>combatStateLog</k> строку <s>"in"</s>;</t>
<t>если event равен <s>"PLAYER_REGEN_ENABLED"</s>, записывает в глобальную переменную <k>combatStateLog</k> строку <s>"out"</s>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseMultiEventFrame
]=],
requireKeywords = {
"CourseMultiEventFrame",
"CreateFrame",
"Frame",
"UIParent",
"RegisterEvent",
"PLAYER_REGEN_DISABLED",
"PLAYER_REGEN_ENABLED",
"SetScript",
"OnEvent",
"combatStateLog",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseMultiEventFrame
if not f then
    _G.checkError = "CourseMultiEventFrame не был создан"
    return false
end
local script = f:GetScript("OnEvent")
if type(script) ~= "function" then
    _G.checkError = "У фрейма должен быть обработчик OnEvent"
    return false
end
-- Вызываем обработчик вручную, чтобы проверить логику
_G.combatStateLog = nil
local ok1, err1 = pcall(script, f, "PLAYER_REGEN_DISABLED")
if not ok1 then
    _G.checkError = "Ошибка при вызове OnEvent с PLAYER_REGEN_DISABLED: " .. tostring(err1)
    return false
end
if _G.combatStateLog ~= "in" then
    _G.checkError = "После PLAYER_REGEN_DISABLED combatStateLog должен быть 'in'"
    return false
end
_G.combatStateLog = nil
local ok2, err2 = pcall(script, f, "PLAYER_REGEN_ENABLED")
if not ok2 then
    _G.checkError = "Ошибка при вызове OnEvent с PLAYER_REGEN_ENABLED: " .. tostring(err2)
    return false
end
if _G.combatStateLog ~= "out" then
    _G.checkError = "После PLAYER_REGEN_ENABLED combatStateLog должен быть 'out'"
    return false
end
return true
end,
}

ns_llua['lua'][243] = {
type = "commenttest",
title = "Тест 239-4: функция CreateEventLogger",
helpModules = {239, 215, 45, 65},
preloadVars = {
{var = "CreateEventLogger", desc = "CreateEventLogger очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 239-4: функция CreateEventLogger</h>
<t>Создай глобальную функцию <k>CreateEventLogger(eventName)</k>.</t>
<t>Требования:</t>
<t>- если <k>eventName</k> не является строкой или является пустой строкой, верни <k>nil</k>;</t>
<t>- иначе создай анонимный фрейм типа <s>"Frame"</s> с родителем <k>UIParent</k>;</t>
<t>- зарегистрируй событие через <k>RegisterEvent(eventName)</k>;</t>
<t>- создай таблицу с полями:</t>
<c>frame</c> — созданный фрейм.
<c>count</c> — число, изначально 0.
<c>lastEvent</c> — строка, изначально пустая строка.
<t>- назначь обработчик OnEvent, который увеличивает <k>count</k> на 1 и записывает <k>event</k> в <k>lastEvent</k>;</t>
<t>- верни таблицу.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateEventLogger(eventName)
]=],
requireKeywords = {
"CreateEventLogger",
"function",
"CreateFrame",
"Frame",
"UIParent",
"RegisterEvent",
"SetScript",
"OnEvent",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateEventLogger) ~= "function" then
    _G.checkError = "CreateEventLogger не является глобальной функцией"
    return false
end
-- Тест 1: корректное событие
local ok1, logger1 = pcall(_G.CreateEventLogger, "PLAYER_TARGET_CHANGED")
if not ok1 then
    _G.checkError = "Ошибка вызова CreateEventLogger: " .. tostring(logger1)
    return false
end
if type(logger1) ~= "table" then
    _G.checkError = "Функция должна вернуть таблицу"
    return false
end
if not logger1.frame then
    _G.checkError = "В таблице должно быть поле frame"
    return false
end
if logger1.count ~= 0 then
    _G.checkError = "Начальное значение count должно быть 0"
    return false
end
if logger1.lastEvent ~= "" then
    _G.checkError = "Начальное значение lastEvent должно быть пустой строкой"
    return false
end
-- Вызываем OnEvent вручную
local script = logger1.frame:GetScript("OnEvent")
if type(script) ~= "function" then
    _G.checkError = "У фрейма должен быть обработчик OnEvent"
    return false
end
local ok2, err2 = pcall(script, logger1.frame, "PLAYER_TARGET_CHANGED")
if not ok2 then
    _G.checkError = "Ошибка при вызове OnEvent: " .. tostring(err2)
    return false
end
if logger1.count ~= 1 then
    _G.checkError = "После одного события count должен быть 1"
    return false
end
if logger1.lastEvent ~= "PLAYER_TARGET_CHANGED" then
    _G.checkError = "lastEvent должен содержать имя события"
    return false
end
-- Тест 2: пустая строка
local ok3, logger2 = pcall(_G.CreateEventLogger, "")
if not ok3 or logger2 ~= nil then
    _G.checkError = "Для пустой строки функция должна вернуть nil"
    return false
end
-- Тест 3: не строка
local ok4, logger3 = pcall(_G.CreateEventLogger, 123)
if not ok4 or logger3 ~= nil then
    _G.checkError = "Для нестрокового аргумента функция должна вернуть nil"
    return false
end
return true
end,
}

ns_llua['lua'][244] = {
type = "commenttest",
title = "Тест 239-5: функция CreateHealthWatcher",
helpModules = {239, 215, 83, 65, 45},
preloadVars = {
{var = "CreateHealthWatcher", desc = "CreateHealthWatcher очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 239-5: функция CreateHealthWatcher</h>
<t>Создай глобальную функцию <k>CreateHealthWatcher(unit)</k>.</t>
<t>Требования:</t>
<t>- если <k>unit</k> не является строкой или является пустой строкой, верни <k>nil</k>;</t>
<t>- иначе создай анонимный фрейм типа <s>"Frame"</s> с родителем <k>UIParent</k>;</t>
<t>- зарегистрируй событие <s>"UNIT_HEALTH"</s> через <k>RegisterEvent</k>;</t>
<t>- создай таблицу с полями:</t>
<c>frame</c> — созданный фрейм.
<c>unit</c> — строка unit.
<c>lastHP</c> — число, изначально 0.
<c>updateCount</c> — число, изначально 0.
<t>- назначь обработчик OnEvent, который:</t>
<t>если аргумент unit события совпадает с сохранённым unit, увеличивает <k>updateCount</k> на 1 и записывает текущее здоровье через <k>UnitHealth(unit) or 0</k> в <k>lastHP</k>;</t>
<t>- верни таблицу.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateHealthWatcher(unit)
]=],
requireKeywords = {
"CreateHealthWatcher",
"function",
"CreateFrame",
"Frame",
"UIParent",
"RegisterEvent",
"UNIT_HEALTH",
"SetScript",
"OnEvent",
"UnitHealth",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateHealthWatcher) ~= "function" then
    _G.checkError = "CreateHealthWatcher не является глобальной функцией"
    return false
end
-- Тест 1: корректный unit
local ok1, watcher = pcall(_G.CreateHealthWatcher, "player")
if not ok1 then
    _G.checkError = "Ошибка вызова CreateHealthWatcher: " .. tostring(watcher)
    return false
end
if type(watcher) ~= "table" then
    _G.checkError = "Функция должна вернуть таблицу"
    return false
end
if not watcher.frame then
    _G.checkError = "В таблице должно быть поле frame"
    return false
end
if watcher.unit ~= "player" then
    _G.checkError = "Поле unit должно быть 'player'"
    return false
end
if watcher.lastHP ~= 0 then
    _G.checkError = "Начальное значение lastHP должно быть 0"
    return false
end
if watcher.updateCount ~= 0 then
    _G.checkError = "Начальное значение updateCount должно быть 0"
    return false
end
-- Вызываем OnEvent вручную с правильным unit
local script = watcher.frame:GetScript("OnEvent")
if type(script) ~= "function" then
    _G.checkError = "У фрейма должен быть обработчик OnEvent"
    return false
end
local ok2, err2 = pcall(script, watcher.frame, "UNIT_HEALTH", "player")
if not ok2 then
    _G.checkError = "Ошибка при вызове OnEvent: " .. tostring(err2)
    return false
end
if watcher.updateCount ~= 1 then
    _G.checkError = "После одного события updateCount должен быть 1"
    return false
end
-- Вызываем с другим unit — не должно меняться
local ok3, err3 = pcall(script, watcher.frame, "UNIT_HEALTH", "target")
if not ok3 then
    _G.checkError = "Ошибка при вызове OnEvent с target: " .. tostring(err3)
    return false
end
if watcher.updateCount ~= 1 then
    _G.checkError = "Для другого unit updateCount не должен меняться"
    return false
end
-- Тест 2: пустая строка
local ok4, watcher2 = pcall(_G.CreateHealthWatcher, "")
if not ok4 or watcher2 ~= nil then
    _G.checkError = "Для пустой строки функция должна вернуть nil"
    return false
end
-- Тест 3: не строка
local ok5, watcher3 = pcall(_G.CreateHealthWatcher, 123)
if not ok5 or watcher3 ~= nil then
    _G.checkError = "Для нестрокового аргумента функция должна вернуть nil"
    return false
end
return true
end,
}

ns_llua['lua'][245] = {
type = "info",
title = "OnUpdate: таймеры и ручная имитация анимаций",
helpModules = {215, 221, 227},
content = [=[
<h>OnUpdate: таймеры и ручная имитация анимаций</h>
<w>Важно:</w> в WoW 3.3.5 нет готовых анимаций и системы AnimationGroup. Всё, что связано с движением, мерцанием, плавным появлением и исчезновением, делается вручную через <k>OnUpdate</k>.
<h>Что такое OnUpdate</h>
<t>Скрипт <k>OnUpdate</k> вызывается каждый кадр для фрейма. Это примерно 30-60 раз в секунду, в зависимости от FPS.</t>
<code>
MyTimerFrame = CreateFrame("Frame", nil, UIParent)
MyTimerFrame:SetScript("OnUpdate", function(self, elapsed)
    -- этот код выполняется каждый кадр
end)
</code>
<t>Аргументы обработчика:</t>
<c>self</c> — сам фрейм.
<c>elapsed</c> — время в секундах, прошедшее с последнего кадра. Обычно очень маленькое число, например 0.016.
<h>Накопление времени</h>
<t>Чтобы отсчитать нужное количество секунд, накапливают <k>elapsed</k> в переменной.</t>
<code>
MyTimerFrame.elapsed = 0
MyTimerFrame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= 5 then
        print("Прошло 5 секунд")
        self:SetScript("OnUpdate", nil)
    end
end)
</code>
<t>Когда время вышло, скрипт снимают через <k>SetScript("OnUpdate", nil)</k>, чтобы он больше не выполнялся.</t>
<h>Почему elapsed, а не GetTime</h>
<t><k>elapsed</k> даёт точное время между кадрами. Это удобно для плавных анимаций, потому что скорость анимации не зависит от FPS.</t>
<code>
-- неправильно: привязка к FPS
self.alpha = self.alpha + 0.01
-- правильно: привязка ко времени
self.alpha = self.alpha + elapsed * speed
</code>
<h>Одноразовый таймер</h>
<code>
function CreateOneShotTimer(seconds, callback)
    local f = CreateFrame("Frame", nil, UIParent)
    f.elapsed = 0
    f:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= seconds then
            self:SetScript("OnUpdate", nil)
            if type(callback) == "function" then
                callback()
            end
        end
    end)
    return f
end
</code>
<h>Повторяющийся таймер</h>
<code>
function CreateRepeatingTimer(seconds, callback)
    local f = CreateFrame("Frame", nil, UIParent)
    f.elapsed = 0
    f:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= seconds then
            self.elapsed = self.elapsed - seconds
            if type(callback) == "function" then
                callback()
            end
        end
    end)
    return f
end
</code>
<t>Здесь вместо снятия скрипта мы вычитаем прошедшее время, чтобы следующий интервал начался с остатка.</t>
<h>Ручная имитация анимации: плавное появление</h>
<code>
function CreateFadeIn(frame, duration)
    frame:SetAlpha(0)
    frame.elapsed = 0
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        local progress = self.elapsed / duration
        if progress >= 1 then
            progress = 1
            self:SetScript("OnUpdate", nil)
        end
        self:SetAlpha(progress)
    end)
end
</code>
<h>Ручная имитация анимации: плавное исчезновение</h>
<code>
function CreateFadeOut(frame, duration)
    frame:SetAlpha(1)
    frame.elapsed = 0
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        local progress = self.elapsed / duration
        if progress >= 1 then
            progress = 1
            self:SetScript("OnUpdate", nil)
        end
        self:SetAlpha(1 - progress)
    end)
end
</code>
<h>Ручная имитация анимации: мерцание</h>
<code>
function CreateBlink(frame, interval)
    frame.elapsed = 0
    frame.visible = true
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= interval then
            self.elapsed = self.elapsed - interval
            self.visible = not self.visible
            if self.visible then
                self:Show()
            else
                self:Hide()
            end
        end
    end)
end
</code>
<h>Ручная имитация анимации: пульсация масштаба</h>
<code>
function CreatePulse(frame, speed)
    frame.elapsed = 0
    frame.growing = true
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        local scale = self:GetScale()
        if self.growing then
            scale = scale + elapsed * speed
            if scale >= 1.2 then
                scale = 1.2
                self.growing = false
            end
        else
            scale = scale - elapsed * speed
            if scale <= 1.0 then
                scale = 1.0
                self.growing = true
            end
        end
        self:SetScale(scale)
    end)
end
</code>
<h>Ручная имитация анимации: обратный отсчёт</h>
<code>
function CreateCountdownDisplay(frame, seconds)
    frame.remaining = seconds
    frame.elapsed = 0
    local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fs:SetPoint("CENTER")
    fs:SetText(tostring(seconds))
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= 1 then
            self.elapsed = self.elapsed - 1
            self.remaining = self.remaining - 1
            if self.remaining <= 0 then
                fs:SetText("Готово!")
                self:SetScript("OnUpdate", nil)
            else
                fs:SetText(tostring(self.remaining))
            end
        end
    end)
end
</code>
<h>Частые ошибки</h>
<w>Ошибка 1:</w> забыть снять OnUpdate, когда анимация закончилась. Фрейм будет продолжать выполняться каждый кадр и тратить ресурсы.
<code>
-- неправильно: OnUpdate работает бесконечно
frame:SetScript("OnUpdate", function(self, elapsed)
    self:SetAlpha(self:GetAlpha() - 0.01)
end)
-- правильно: снимаем после завершения
frame:SetScript("OnUpdate", function(self, elapsed)
    local alpha = self:GetAlpha() - elapsed
    if alpha <= 0 then
        self:SetAlpha(0)
        self:SetScript("OnUpdate", nil)
    else
        self:SetAlpha(alpha)
    end
end)
</code>
<w>Ошибка 2:</w> не привязывать скорость к <k>elapsed</k>. Анимация будет зависеть от FPS.
<w>Ошибка 3:</w> использовать <k>GetTime()</k> внутри OnUpdate вместо накопления <k>elapsed</k>. Это работает, но менее точно и менее удобно для пауз.
]=],
}

ns_llua['lua'][246] = {
type = "vartest",
title = "Тест 245-1: базовые понятия OnUpdate",
helpModules = {245},
tasks = {
{
var = "onUpdateArgName",
desc = 'Создай глобальную переменную onUpdateArgName = "elapsed"',
check = function(value)
return value == "elapsed"
end,
},
{
var = "onUpdateStopMethod",
desc = 'Создай глобальную переменную onUpdateStopMethod = "SetScript"',
check = function(value)
return value == "SetScript"
end,
},
{
var = "onUpdateStopValue",
desc = 'Создай глобальную переменную onUpdateStopValue = nil',
check = function(value)
return value == nil
end,
},
},
}

ns_llua['lua'][247] = {
type = "commenttest",
title = "Тест 245-2: функция CreateOneShotTimer",
helpModules = {245, 215, 45},
preloadVars = {
{var = "CreateOneShotTimer", desc = "CreateOneShotTimer очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
{var = "testTimerFired", desc = "testTimerFired очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 245-2: функция CreateOneShotTimer</h>
<t>Создай глобальную функцию <k>CreateOneShotTimer(seconds, callback)</k>.</t>
<t>Требования:</t>
<t>- если <k>seconds</k> не является числом или меньше либо равно нуля, функция должна вернуть <k>nil</k>;</t>
<t>- иначе создай анонимный фрейм типа <s>"Frame"</s> с родителем <k>UIParent</k>;</t>
<t>- создай поле <k>elapsed</k> со значением <n>0</n>;</t>
<t>- назначь скрипт <k>OnUpdate</k>, который:</t>
<t>накапливает <k>elapsed</k>;</t>
<t>когда накопленное время больше или равно <k>seconds</k>, снимает скрипт через <k>SetScript("OnUpdate", nil)</k> и вызывает <k>callback</k>, если это функция;</t>
<t>- верни фрейм.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateOneShotTimer(seconds, callback)
]=],
requireKeywords = {
"CreateOneShotTimer",
"function",
"CreateFrame",
"Frame",
"UIParent",
"SetScript",
"OnUpdate",
"elapsed",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateOneShotTimer) ~= "function" then
    _G.checkError = "CreateOneShotTimer не является глобальной функцией"
    return false
end
-- Тест 1: некорректные секунды
local ok1, result1 = pcall(_G.CreateOneShotTimer, -1, nil)
if not ok1 or result1 ~= nil then
    _G.checkError = "Для отрицательных секунд функция должна вернуть nil"
    return false
end
local ok2, result2 = pcall(_G.CreateOneShotTimer, "bad", nil)
if not ok2 or result2 ~= nil then
    _G.checkError = "Для нечисловых секунд функция должна вернуть nil"
    return false
end
-- Тест 2: корректный вызов
_G.testTimerFired = false
local ok3, timerFrame = pcall(_G.CreateOneShotTimer, 0.01, function()
    _G.testTimerFired = true
end)
if not ok3 then
    _G.checkError = "Ошибка вызова CreateOneShotTimer: " .. tostring(timerFrame)
    return false
end
if not timerFrame or type(timerFrame.SetScript) ~= "function" then
    _G.checkError = "Функция должна вернуть фрейм"
    return false
end
if timerFrame.elapsed ~= 0 then
    _G.checkError = "Поле elapsed должно быть 0"
    return false
end
local script = timerFrame:GetScript("OnUpdate")
if type(script) ~= "function" then
    _G.checkError = "У фрейма должен быть обработчик OnUpdate"
    return false
end
-- Вызываем OnUpdate вручную с большим elapsed, чтобы сработал таймер
local ok4, err4 = pcall(script, timerFrame, 1)
if not ok4 then
    _G.checkError = "Ошибка при вызове OnUpdate: " .. tostring(err4)
    return false
end
if _G.testTimerFired ~= true then
    _G.checkError = "Callback должен быть вызван после истечения времени"
    return false
end
-- После срабатывания OnUpdate должен быть снят
local scriptAfter = timerFrame:GetScript("OnUpdate")
if scriptAfter ~= nil then
    _G.checkError = "После срабатывания таймера OnUpdate должен быть снят"
    return false
end
return true
end,
}

ns_llua['lua'][248] = {
type = "commenttest",
title = "Тест 245-3: функция CreateBlinkAnimation",
helpModules = {245, 215, 45},
preloadVars = {
{var = "CreateBlinkAnimation", desc = "CreateBlinkAnimation очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 245-3: функция CreateBlinkAnimation</h>
<t>Создай глобальную функцию <k>CreateBlinkAnimation(frame, interval)</k>.</t>
<t>Требования:</t>
<t>- если <k>frame</k> не существует или у него нет метода <k>Show</k> или <k>Hide</k>, функция должна вернуть <k>nil</k>;</t>
<t>- если <k>interval</k> не является числом или меньше либо равно нуля, функция должна вернуть <k>nil</k>;</t>
<t>- иначе создай поле <k>elapsed</k> со значением <n>0</n> на фрейме;</t>
<t>- создай поле <k>visible</k> со значением <k>true</k> на фрейме;</t>
<t>- назначь скрипт <k>OnUpdate</k>, который:</t>
<t>накапливает <k>elapsed</k>;</t>
<t>когда накопленное время больше или равно <k>interval</k>, вычитает <k>interval</k> из <k>elapsed</k>, переключает <k>visible</k> и вызывает <k>Show()</k> или <k>Hide()</k>;</t>
<t>- верни фрейм.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateBlinkAnimation(frame, interval)
]=],
requireKeywords = {
"CreateBlinkAnimation",
"function",
"Show",
"Hide",
"SetScript",
"OnUpdate",
"elapsed",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateBlinkAnimation) ~= "function" then
    _G.checkError = "CreateBlinkAnimation не является глобальной функцией"
    return false
end
-- Тест 1: некорректные аргументы
local ok1, result1 = pcall(_G.CreateBlinkAnimation, nil, 1)
if not ok1 or result1 ~= nil then
    _G.checkError = "Для nil-фрейма функция должна вернуть nil"
    return false
end
local testFrame = CreateFrame("Frame", nil, UIParent)
local ok2, result2 = pcall(_G.CreateBlinkAnimation, testFrame, -1)
if not ok2 or result2 ~= nil then
    _G.checkError = "Для отрицательного interval функция должна вернуть nil"
    return false
end
-- Тест 2: корректный вызов
local ok3, result3 = pcall(_G.CreateBlinkAnimation, testFrame, 0.5)
if not ok3 then
    _G.checkError = "Ошибка вызова CreateBlinkAnimation: " .. tostring(result3)
    return false
end
if not result3 or type(result3.Show) ~= "function" then
    _G.checkError = "Функция должна вернуть фрейм"
    return false
end
if result3.elapsed ~= 0 then
    _G.checkError = "Поле elapsed должно быть 0"
    return false
end
if result3.visible ~= true then
    _G.checkError = "Поле visible должно быть true"
    return false
end
local script = result3:GetScript("OnUpdate")
if type(script) ~= "function" then
    _G.checkError = "У фрейма должен быть обработчик OnUpdate"
    return false
end
-- Вызываем OnUpdate вручную, чтобы проверить переключение
result3:Show()
local ok4, err4 = pcall(script, result3, 1)
if not ok4 then
    _G.checkError = "Ошибка при вызове OnUpdate: " .. tostring(err4)
    return false
end
if result3.visible ~= false then
    _G.checkError = "После первого интервала visible должен быть false"
    return false
end
if result3:IsShown() then
    _G.checkError = "После первого интервала фрейм должен быть скрыт"
    return false
end
-- Второй вызов должен вернуть видимость
local ok5, err5 = pcall(script, result3, 1)
if not ok5 then
    _G.checkError = "Ошибка при втором вызове OnUpdate: " .. tostring(err5)
    return false
end
if result3.visible ~= true then
    _G.checkError = "После второго интервала visible должен быть true"
    return false
end
if not result3:IsShown() then
    _G.checkError = "После второго интервала фрейм должен быть показан"
    return false
end
return true
end,
}

ns_llua['lua'][249] = {
type = "commenttest",
title = "Тест 245-4: функция CreateFadeOutAnimation",
helpModules = {245, 215, 45, 10},
preloadVars = {
{var = "CreateFadeOutAnimation", desc = "CreateFadeOutAnimation очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 245-4: функция CreateFadeOutAnimation</h>
<t>Создай глобальную функцию <k>CreateFadeOutAnimation(frame, duration)</k>.</t>
<t>Требования:</t>
<t>- если <k>frame</k> не существует или у него нет метода <k>SetAlpha</k>, функция должна вернуть <k>nil</k>;</t>
<t>- если <k>duration</k> не является числом или меньше либо равно нуля, функция должна вернуть <k>nil</k>;</t>
<t>- иначе установи начальную прозрачность <k>SetAlpha(1)</k>;</t>
<t>- создай поле <k>elapsed</k> со значением <n>0</n> на фрейме;</t>
<t>- назначь скрипт <k>OnUpdate</k>, который:</t>
<t>накапливает <k>elapsed</k>;</t>
<t>вычисляет прогресс как <k>elapsed / duration</k>;</t>
<t>если прогресс больше или равен 1, устанавливает <k>SetAlpha(0)</k> и снимает скрипт;</t>
<t>иначе устанавливает <k>SetAlpha(1 - progress)</k>;</t>
<t>- верни фрейм.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateFadeOutAnimation(frame, duration)
]=],
requireKeywords = {
"CreateFadeOutAnimation",
"function",
"SetAlpha",
"SetScript",
"OnUpdate",
"elapsed",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateFadeOutAnimation) ~= "function" then
    _G.checkError = "CreateFadeOutAnimation не является глобальной функцией"
    return false
end
-- Тест 1: некорректные аргументы
local ok1, result1 = pcall(_G.CreateFadeOutAnimation, nil, 1)
if not ok1 or result1 ~= nil then
    _G.checkError = "Для nil-фрейма функция должна вернуть nil"
    return false
end
local testFrame = CreateFrame("Frame", nil, UIParent)
local ok2, result2 = pcall(_G.CreateFadeOutAnimation, testFrame, -1)
if not ok2 or result2 ~= nil then
    _G.checkError = "Для отрицательного duration функция должна вернуть nil"
    return false
end
-- Тест 2: корректный вызов
local ok3, result3 = pcall(_G.CreateFadeOutAnimation, testFrame, 2)
if not ok3 then
    _G.checkError = "Ошибка вызова CreateFadeOutAnimation: " .. tostring(result3)
    return false
end
if not result3 or type(result3.SetAlpha) ~= "function" then
    _G.checkError = "Функция должна вернуть фрейм"
    return false
end
if result3.elapsed ~= 0 then
    _G.checkError = "Поле elapsed должно быть 0"
    return false
end
local alpha = result3:GetAlpha()
if type(alpha) ~= "number" or math.abs(alpha - 1) > 0.01 then
    _G.checkError = "Начальная прозрачность должна быть 1"
    return false
end
local script = result3:GetScript("OnUpdate")
if type(script) ~= "function" then
    _G.checkError = "У фрейма должен быть обработчик OnUpdate"
    return false
end
-- Вызываем OnUpdate вручную с половиной duration
local ok4, err4 = pcall(script, result3, 1)
if not ok4 then
    _G.checkError = "Ошибка при вызове OnUpdate: " .. tostring(err4)
    return false
end
local alphaMid = result3:GetAlpha()
if type(alphaMid) ~= "number" or alphaMid > 0.6 or alphaMid < 0.4 then
    _G.checkError = "После половины duration прозрачность должна быть около 0.5"
    return false
end
-- Вызываем OnUpdate с оставшимся временем
local ok5, err5 = pcall(script, result3, 2)
if not ok5 then
    _G.checkError = "Ошибка при втором вызове OnUpdate: " .. tostring(err5)
    return false
end
local alphaEnd = result3:GetAlpha()
if type(alphaEnd) ~= "number" or alphaEnd > 0.01 then
    _G.checkError = "После завершения прозрачность должна быть 0"
    return false
end
-- После завершения OnUpdate должен быть снят
local scriptAfter = result3:GetScript("OnUpdate")
if scriptAfter ~= nil then
    _G.checkError = "После завершения анимации OnUpdate должен быть снят"
    return false
end
return true
end,
}

ns_llua['lua'][250] = {
type = "commenttest",
title = "Тест 245-5: функция CreateCountdownDisplay",
helpModules = {245, 215, 227, 45, 10},
preloadVars = {
{var = "CreateCountdownDisplay", desc = "CreateCountdownDisplay очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 245-5: функция CreateCountdownDisplay</h>
<t>Создай глобальную функцию <k>CreateCountdownDisplay(frame, seconds)</k>.</t>
<t>Требования:</t>
<t>- если <k>frame</k> не существует или у него нет метода <k>CreateFontString</k>, функция должна вернуть <k>nil</k>;</t>
<t>- если <k>seconds</k> не является целым числом или меньше либо равно нуля, функция должна вернуть <k>nil</k>;</t>
<t>- иначе создай FontString слоем <s>"OVERLAY"</s> с шаблоном <s>"GameFontNormalLarge"</s>;</t>
<t>- прикрепи текст через <k>SetPoint("CENTER")</k>;</t>
<t>- установи начальный текст как строку с числом <k>seconds</k>;</t>
<t>- создай поле <k>remaining</k> со значением <k>seconds</k> на фрейме;</t>
<t>- создай поле <k>elapsed</k> со значением <n>0</n> на фрейме;</t>
<t>- назначь скрипт <k>OnUpdate</k>, который:</t>
<t>накапливает <k>elapsed</k>;</t>
<t>когда накопленное время больше или равно 1, вычитает 1 из <k>elapsed</k> и уменьшает <k>remaining</k> на 1;</t>
<t>если <k>remaining</k> меньше или равно нуля, устанавливает текст <s>"Готово!"</s> и снимает скрипт;</t>
<t>иначе устанавливает текст как строку с числом <k>remaining</k>;</t>
<t>- верни фрейм.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateCountdownDisplay(frame, seconds)
]=],
requireKeywords = {
"CreateCountdownDisplay",
"function",
"CreateFontString",
"OVERLAY",
"GameFontNormalLarge",
"SetPoint",
"SetText",
"SetScript",
"OnUpdate",
"elapsed",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateCountdownDisplay) ~= "function" then
    _G.checkError = "CreateCountdownDisplay не является глобальной функцией"
    return false
end
-- Тест 1: некорректные аргументы
local ok1, result1 = pcall(_G.CreateCountdownDisplay, nil, 5)
if not ok1 or result1 ~= nil then
    _G.checkError = "Для nil-фрейма функция должна вернуть nil"
    return false
end
local testFrame = CreateFrame("Frame", nil, UIParent)
testFrame:SetSize(200, 100)
local ok2, result2 = pcall(_G.CreateCountdownDisplay, testFrame, -1)
if not ok2 or result2 ~= nil then
    _G.checkError = "Для отрицательного seconds функция должна вернуть nil"
    return false
end
local ok3, result3 = pcall(_G.CreateCountdownDisplay, testFrame, 1.5)
if not ok3 or result3 ~= nil then
    _G.checkError = "Для дробного seconds функция должна вернуть nil"
    return false
end
-- Тест 2: корректный вызов
local ok4, result4 = pcall(_G.CreateCountdownDisplay, testFrame, 3)
if not ok4 then
    _G.checkError = "Ошибка вызова CreateCountdownDisplay: " .. tostring(result4)
    return false
end
if not result4 or type(result4.CreateFontString) ~= "function" then
    _G.checkError = "Функция должна вернуть фрейм"
    return false
end
if result4.remaining ~= 3 then
    _G.checkError = "Поле remaining должно быть 3"
    return false
end
if result4.elapsed ~= 0 then
    _G.checkError = "Поле elapsed должно быть 0"
    return false
end
local script = result4:GetScript("OnUpdate")
if type(script) ~= "function" then
    _G.checkError = "У фрейма должен быть обработчик OnUpdate"
    return false
end
-- Вызываем OnUpdate вручную, чтобы проверить отсчёт
local ok5, err5 = pcall(script, result4, 1)
if not ok5 then
    _G.checkError = "Ошибка при вызове OnUpdate: " .. tostring(err5)
    return false
end
if result4.remaining ~= 2 then
    _G.checkError = "После первой секунды remaining должен быть 2"
    return false
end
local ok6, err6 = pcall(script, result4, 1)
if not ok6 then
    _G.checkError = "Ошибка при втором вызове OnUpdate: " .. tostring(err6)
    return false
end
if result4.remaining ~= 1 then
    _G.checkError = "После второй секунды remaining должен быть 1"
    return false
end
local ok7, err7 = pcall(script, result4, 1)
if not ok7 then
    _G.checkError = "Ошибка при третьем вызове OnUpdate: " .. tostring(err7)
    return false
end
if result4.remaining ~= 0 then
    _G.checkError = "После третьей секунды remaining должен быть 0"
    return false
end
-- После завершения OnUpdate должен быть снят
local scriptAfter = result4:GetScript("OnUpdate")
if scriptAfter ~= nil then
    _G.checkError = "После завершения отсчёта OnUpdate должен быть снят"
    return false
end
return true
end,
}

ns_llua['lua'][251] = {
type = "info",
title = "Книга заклинаний и HasSpell",
helpModules = {191, 65, 45},
content = [=[
<h>Книга заклинаний и HasSpell</h>
<t>Книга заклинаний — это список всех заклинаний, которые персонаж выучил. Она разбита на вкладки.</t>
<w>Важно:</w> в WoW 3.3.5 нет готовой функции <k>IsSpellKnown</k> и нет готовой функции <k>HasSpell</k>. Чтобы проверить, знает ли персонаж заклинание, нужно перебрать книгу заклинаний вручную.
<h>Вкладки книги</h>
<t>Книга заклинаний состоит из вкладок. Обычно это:</t>
<c>1</c> — основные заклинания класса.
<c>2</c> — таланты.
<c>3</c> — общие заклинания.
<c>4</c> — профессии и другие.
<h>GetNumSpellTabs</h>
<code>
/run print(GetNumSpellTabs())
</code>
<t>Возвращает количество вкладок книги заклинаний.</t>
<h>GetSpellTabInfo</h>
<code>
/run local name, texture, offset, numSpells = GetSpellTabInfo(1); print(name, offset, numSpells)
</code>
<t>Возвращает данные о вкладке:</t>
<c>name</c> — название вкладки.
<c>texture</c> — иконка вкладки.
<c>offset</c> — смещение индекса. Заклинания этой вкладки начинаются с offset + 1.
<c>numSpells</c> — количество заклинаний на вкладке.
<h>GetSpellBookItemName</h>
<code>
/run print(GetSpellBookItemName(1, "SPELL"))
</code>
<t>Возвращает имя заклинания по глобальному индексу в книге.</t>
<t>Второй аргумент — тип книги:</t>
<c>"SPELL"</c> — книга заклинаний.
<c>"PET"</c> — книга заклинаний питомца.
<h>GetSpellBookItemTexture</h>
<code>
/run print(GetSpellBookItemTexture(1, "SPELL"))
</code>
<t>Возвращает путь к иконке заклинания.</t>
<h>Перебор книги заклинаний</h>
<code>
/run local total = 0; local tabs = GetNumSpellTabs() or 0; for tab = 1, tabs do local _, _, offset, numSpells = GetSpellTabInfo(tab); if numSpells then total = total + numSpells end end; print("Всего заклинаний: " .. total)
</code>
<h>Поиск заклинания по имени</h>
<t>Чтобы проверить, знает ли персонаж заклинание, нужно перебрать книгу:</t>
<code>
/run local found = false; local tabs = GetNumSpellTabs() or 0; for tab = 1, tabs do local _, _, offset, numSpells = GetSpellTabInfo(tab); if numSpells then for i = 1, numSpells do local name = GetSpellBookItemName(offset + i, "SPELL"); if name and string.find(name, "Огн") then found = true end end end end; print(found)
</code>
<w>Важно:</w> имя заклинания зависит от языка клиента. Поэтому для надёжной проверки лучше использовать spellID, если он доступен.
<h>Поиск по spellID через GetSpellBookItemName</h>
<t>В WoW 3.3.5 нет прямой функции поиска по spellID в книге. Однако можно использовать <k>GetSpellInfo(spellID)</k> чтобы получить имя, а затем искать это имя в книге.</t>
<code>
/run local spellName = GetSpellInfo(6603); if spellName then print("Имя заклинания 6603: " .. spellName) end
</code>
<h>Безопасный шаблон</h>
<code>
/run local tabs = GetNumSpellTabs() or 0; print(string.format("Вкладок в книге: %d", tabs))
</code>
]=],
}

ns_llua['lua'][252] = {
type = "vartest",
title = "Тест 251-1: количество вкладок книги",
helpModules = {251, 65},
tasks = {
{
var = "spellTabCount",
desc = 'Создай глобальную переменную spellTabCount = GetNumSpellTabs() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "firstTabName",
desc = 'Создай глобальную переменную firstTabName = GetSpellTabInfo(1) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][253] = {
type = "vartest",
title = "Тест 251-2: данные первой вкладки",
helpModules = {251, 65},
tasks = {
{
var = "firstTabOffset",
desc = 'Создай глобальную переменную firstTabOffset = select(3, GetSpellTabInfo(1)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "firstTabSpellCount",
desc = 'Создай глобальную переменную firstTabSpellCount = select(4, GetSpellTabInfo(1)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "firstSpellName",
desc = 'Создай глобальную переменную firstSpellName = GetSpellBookItemName(1, "SPELL") or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][254] = {
type = "commenttest",
title = "Тест 251-3: функция GetSpellTabCountSafe",
helpModules = {251, 45, 65},
preloadVars = {
{var = "GetSpellTabCountSafe", desc = "GetSpellTabCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 251-3: функция GetSpellTabCountSafe</h>
<t>Создай глобальную функцию <k>GetSpellTabCountSafe()</k>.</t>
<t>Функция должна вернуть количество вкладок книги заклинаний через:</t>
<code>
GetNumSpellTabs()
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество вкладок.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSpellTabCountSafe()
]=],
requireKeywords = {
"GetSpellTabCountSafe",
"function",
"GetNumSpellTabs",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSpellTabCountSafe) ~= "function" then
_G.checkError = "GetSpellTabCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetSpellTabCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetSpellTabCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество вкладок не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][255] = {
type = "commenttest",
title = "Тест 251-4: функция GetSpellBookItemNameSafe",
helpModules = {251, 45, 65},
preloadVars = {
{var = "GetSpellBookItemNameSafe", desc = "GetSpellBookItemNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 251-4: функция GetSpellBookItemNameSafe</h>
<t>Создай глобальную функцию <k>GetSpellBookItemNameSafe(index)</k>.</t>
<t>Если <k>index</k> не является числом или меньше либо равно нуля, функция должна вернуть строку:</t>
<s>"нет"</s>
<t>Иначе функция должна получить имя заклинания через:</t>
<code>
GetSpellBookItemName(index, "SPELL")
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"нет"</s>
<t>Иначе функция должна вернуть имя заклинания.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetSpellBookItemNameSafe(index)
]=],
requireKeywords = {
"GetSpellBookItemNameSafe",
"function",
"GetSpellBookItemName",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetSpellBookItemNameSafe) ~= "function" then
_G.checkError = "GetSpellBookItemNameSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetSpellBookItemNameSafe, 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetSpellBookItemNameSafe(1): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для index = 1 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetSpellBookItemNameSafe, 0)
if not ok2 or result2 ~= "нет" then
_G.checkError = "Для index = 0 функция должна вернуть 'нет'"
return false
end
local ok3, result3 = pcall(_G.GetSpellBookItemNameSafe, "bad")
if not ok3 or result3 ~= "нет" then
_G.checkError = "Для нечислового index функция должна вернуть 'нет'"
return false
end
return true
end,
}

ns_llua['lua'][256] = {
type = "commenttest",
title = "Тест 251-5: функция FindSpellInBook",
helpModules = {251, 45, 31, 33, 65},
preloadVars = {
{var = "FindSpellInBook", desc = "FindSpellInBook очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 251-5: функция FindSpellInBook</h>
<t>Создай глобальную функцию <k>FindSpellInBook(text)</k>.</t>
<t>Если <k>text</k> не является строкой или является пустой строкой, функция должна вернуть <k>false</k>.</t>
<t>Иначе функция должна перебрать все вкладки книги заклинаний и найти заклинание, в названии которого есть подстрока <k>text</k>.</t>
<t>Алгоритм:</t>
<t>1. Получи количество вкладок через <k>GetNumSpellTabs()</k>.</t>
<t>2. Для каждой вкладки получи <k>offset</k> и <k>numSpells</k> через <k>GetSpellTabInfo(tab)</k>.</t>
<t>3. Перебери заклинания от <k>offset + 1</k> до <k>offset + numSpells</k>.</t>
<t>4. Для каждого заклинания получи имя через <k>GetSpellBookItemName(index, "SPELL")</k>.</t>
<t>5. Если имя содержит подстроку <k>text</k>, верни <k>true</k>.</t>
<t>6. Если ничего не найдено, верни <k>false</k>.</t>
<t>Используй:</t>
<c>GetNumSpellTabs</c>
<c>GetSpellTabInfo</c>
<c>GetSpellBookItemName</c>
<c>string.find</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию FindSpellInBook(text)
]=],
requireKeywords = {
"FindSpellInBook",
"function",
"GetNumSpellTabs",
"GetSpellTabInfo",
"GetSpellBookItemName",
"string.find",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.FindSpellInBook) ~= "function" then
_G.checkError = "FindSpellInBook не является глобальной функцией"
return false
end
-- Тест 1: пустая строка
local ok1, result1 = pcall(_G.FindSpellInBook, "")
if not ok1 or result1 ~= false then
_G.checkError = "Для пустой строки функция должна вернуть false"
return false
end
-- Тест 2: не строка
local ok2, result2 = pcall(_G.FindSpellInBook, 123)
if not ok2 or result2 ~= false then
_G.checkError = "Для нестрокового аргумента функция должна вернуть false"
return false
end
-- Тест 3: несуществующая подстрока
local ok3, result3 = pcall(_G.FindSpellInBook, "zzz_no_such_spell_zzz")
if not ok3 then
_G.checkError = "Ошибка вызова FindSpellInBook с несуществующей строкой: " .. tostring(result3)
return false
end
if result3 ~= false then
_G.checkError = "Для несуществующей подстроки функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][257] = {
type = "info",
title = "Backdrop: рамки и фоны фреймов",
helpModules = {215, 221, 227},
content = [=[
<h>Backdrop: рамки и фоны фреймов</h>
<t>В WoW 3.3.5 для создания красивых панелей с рамками и фонами используется метод <k>SetBackdrop</k>. Это основной способ стилизации фреймов.</t>
<w>Важно:</w> в современных версиях WoW этот метод убрали и заменили на NineSlice. Но в 3.3.5 именно <k>SetBackdrop</k> — единственный способ.
<h>Структура backdropInfo</h>
<t>Backdrop задаётся таблицей со следующими полями:</t>
<code>
local backdropInfo = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}
</code>
<t>Поля:</t>
<c>bgFile</c> — путь к текстуре фона.
<c>edgeFile</c> — путь к текстуре рамки.
<c>tile</c> — тайлить фон (повторять текстуру).
<c>tileSize</c> — размер тайла фона.
<c>edgeSize</c> — толщина рамки.
<c>insets</c> — отступ фона от краёв рамки.
<h>Применение SetBackdrop</h>
<code>
MyStyledFrame = CreateFrame("Frame", "MyStyledFrame", UIParent)
MyStyledFrame:SetSize(250, 180)
MyStyledFrame:SetPoint("CENTER")
MyStyledFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
MyStyledFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
MyStyledFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
MyStyledFrame:Show()
</code>
<h>SetBackdropColor</h>
<t>Устанавливает цвет фона. Четыре аргумента: R, G, B, A (от 0 до 1).</t>
<code>
MyStyledFrame:SetBackdropColor(0, 0, 0, 0.8)   -- чёрный полупрозрачный
MyStyledFrame:SetBackdropColor(0.2, 0.1, 0.1, 1) -- тёмно-красный
</code>
<h>SetBackdropBorderColor</h>
<t>Устанавливает цвет рамки. Формат тот же: R, G, B, A.</t>
<code>
MyStyledFrame:SetBackdropBorderColor(1, 0.84, 0, 1) -- золотая рамка
</code>
<h>Популярные текстуры Blizzard</h>
<c>"Interface\\Tooltips\\UI-Tooltip-Background"</c> — гладкий фон.
<c>"Interface\\Tooltips\\UI-Tooltip-Border"</c> — тонкая рамка.
<c>"Interface\\DialogFrame\\UI-DialogBox-Background"</c> — фон диалога.
<c>"Interface\\DialogFrame\\UI-DialogBox-Border"</c> — рамка диалога.
<c>"Interface\\ChatFrame\\ChatFrameBackground"</c> — фон чата.
<c>"Interface\\Buttons\\WHITE8x8"</c> — белый квадрат (универсальный).
<h>Шаблоны с backdrop</h>
<t>Некоторые шаблоны уже содержат backdrop:</t>
<code>
MyDialog = CreateFrame("Frame", "MyDialog", UIParent, "UIPanelDialogTemplate")
</code>
<t>Но для полного контроля лучше задавать backdrop вручную.</t>
<h>Частые ошибки</h>
<w>Ошибка 1:</w> забыть двойной обратный слеш в путях.
<code>
-- неправильно
bgFile = "Interface\Tooltips\UI-Tooltip-Background"
-- правильно
bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"
</code>
<w>Ошибка 2:</w> вызвать SetBackdropColor до SetBackdrop. Сначала нужно задать backdrop, потом менять цвет.
<w>Ошибка 3:</w> не указать insets. Без них фон может залезать под рамку.
]=],
}

ns_llua['lua'][258] = {
type = "vartest",
title = "Тест 258: пути текстур backdrop",
helpModules = {257},
tasks = {
{
var = "backdropBgPath",
desc = 'Создай глобальную переменную backdropBgPath = "Interface\\\\Tooltips\\\\UI-Tooltip-Background"',
check = function(value)
return type(value) == "string" and value:find("UI%-Tooltip%-Background") ~= nil
end,
},
{
var = "backdropEdgePath",
desc = 'Создай глобальную переменную backdropEdgePath = "Interface\\\\Tooltips\\\\UI-Tooltip-Border"',
check = function(value)
return type(value) == "string" and value:find("UI%-Tooltip%-Border") ~= nil
end,
},
{
var = "backdropTileSize",
desc = 'Создай глобальную переменную backdropTileSize = 16',
check = function(value)
return type(value) == "number" and value == 16
end,
},
},
}

ns_llua['lua'][259] = {
type = "commenttest",
title = "Тест 259: фрейм с backdrop",
helpModules = {257, 215, 221},
preloadVars = {
{var = "CourseBackdropFrame", desc = "CourseBackdropFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 233-2: фрейм с backdrop</h>
<t>Создай глобальный фрейм <k>CourseBackdropFrame</k>.</t>
<t>Требования:</t>
<t>- тип: <s>"Frame"</s>, глобальное имя: <s>"CourseBackdropFrame"</s>, родитель: <k>UIParent</k>;</t>
<t>- размер: 260 на 160;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- примени <k>SetBackdrop</k> с таблицей:</t>
<c>bgFile</c> = "Interface\\Tooltips\\UI-Tooltip-Background"
<c>edgeFile</c> = "Interface\\Tooltips\\UI-Tooltip-Border"
<c>tile</c> = true
<c>tileSize</c> = 16
<c>edgeSize</c> = 16
<c>insets</c> = { left = 4, right = 4, top = 4, bottom = 4 }
<t>- установи цвет фона: <k>SetBackdropColor(0.05, 0.05, 0.05, 0.9)</k>;</t>
<t>- установи цвет рамки: <k>SetBackdropBorderColor(0.6, 0.6, 0.6, 1)</k>;</t>
<t>- покажи фрейм.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseBackdropFrame с backdrop
]=],
requireKeywords = {
"CourseBackdropFrame",
"CreateFrame",
"SetBackdrop",
"bgFile",
"edgeFile",
"SetBackdropColor",
"SetBackdropBorderColor",
"Show",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseBackdropFrame
if not f or type(f.IsShown) ~= "function" then
_G.checkError = "CourseBackdropFrame не является фреймом"
return false
end
if not f:IsShown() then
_G.checkError = "Фрейм должен быть показан"
return false
end
if f:GetWidth() ~= 260 or f:GetHeight() ~= 160 then
_G.checkError = "Размер фрейма должен быть 260 на 160"
return false
end
if type(f.GetBackdrop) ~= "function" then
_G.checkError = "У фрейма должен быть метод GetBackdrop"
return false
end
local bd = f:GetBackdrop()
if type(bd) ~= "table" then
_G.checkError = "Backdrop не был применён"
return false
end
if type(bd.bgFile) ~= "string" or bd.bgFile == "" then
_G.checkError = "bgFile должен быть непустой строкой"
return false
end
if type(bd.edgeFile) ~= "string" or bd.edgeFile == "" then
_G.checkError = "edgeFile должен быть непустой строкой"
return false
end
return true
end,
}

ns_llua['lua'][260] = {
type = "commenttest",
title = "Тест 260: функция ApplyBackdrop",
helpModules = {257, 215, 45, 65},
preloadVars = {
{var = "ApplyBackdrop", desc = "ApplyBackdrop очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 233-3: функция ApplyBackdrop</h>
<t>Создай глобальную функцию <k>ApplyBackdrop(frame, r, g, b, a)</k>.</t>
<t>Требования:</t>
<t>- если <k>frame</k> не существует или у него нет метода <k>SetBackdrop</k>, верни <k>false</k>;</t>
<t>- если <k>r</k>, <k>g</k>, <k>b</k> не являются числами, верни <k>false</k>;</t>
<t>- если <k>a</k> не является числом, используй <n>1</n>;</t>
<t>- иначе примени стандартный backdrop с bgFile <s>"Interface\\Tooltips\\UI-Tooltip-Background"</s> и edgeFile <s>"Interface\\Tooltips\\UI-Tooltip-Border"</s>;</t>
<t>- установи цвет фона через <k>SetBackdropColor(r, g, b, a)</k>;</t>
<t>- установи цвет рамки через <k>SetBackdropBorderColor(0.5, 0.5, 0.5, 1)</k>;</t>
<t>- верни <k>true</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию ApplyBackdrop(frame, r, g, b, a)
]=],
requireKeywords = {
"ApplyBackdrop",
"function",
"SetBackdrop",
"SetBackdropColor",
"SetBackdropBorderColor",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.ApplyBackdrop) ~= "function" then
_G.checkError = "ApplyBackdrop не является глобальной функцией"
return false
end
local testFrame = CreateFrame("Frame", nil, UIParent)
testFrame:SetSize(100, 100)
local ok1, result1 = pcall(_G.ApplyBackdrop, testFrame, 0.1, 0.1, 0.1, 0.8)
if not ok1 then
_G.checkError = "Ошибка вызова ApplyBackdrop: " .. tostring(result1)
return false
end
if result1 ~= true then
_G.checkError = "Для корректного фрейма функция должна вернуть true"
return false
end
local bd = testFrame:GetBackdrop()
if type(bd) ~= "table" or type(bd.bgFile) ~= "string" then
_G.checkError = "Backdrop не был применён"
return false
end
local ok2, result2 = pcall(_G.ApplyBackdrop, nil, 0, 0, 0, 1)
if not ok2 or result2 ~= false then
_G.checkError = "Для nil-фрейма функция должна вернуть false"
return false
end
local ok3, result3 = pcall(_G.ApplyBackdrop, testFrame, "bad", 0, 0, 1)
if not ok3 or result3 ~= false then
_G.checkError = "Для нечислового r функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][261] = {
type = "commenttest",
title = "Тест 261: функция SetFrameBackdropColor",
helpModules = {257, 45, 65, 21},
preloadVars = {
{var = "SetFrameBackdropColor", desc = "SetFrameBackdropColor очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 233-4: функция SetFrameBackdropColor</h>
<t>Создай глобальную функцию <k>SetFrameBackdropColor(frame, r, g, b, a)</k>.</t>
<t>Требования:</t>
<t>- если <k>frame</k> не существует или у него нет метода <k>SetBackdropColor</k>, верни <k>false</k>;</t>
<t>- если любой из аргументов <k>r</k>, <k>g</k>, <k>b</k> не является числом, верни <k>false</k>;</t>
<t>- если <k>a</k> не является числом, используй <n>1</n>;</t>
<t>- ограничь каждое значение от 0 до 1 через <k>math.max(0, math.min(1, value))</k>;</t>
<t>- вызови <k>frame:SetBackdropColor(r, g, b, a)</k>;</t>
<t>- верни <k>true</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию SetFrameBackdropColor(frame, r, g, b, a)
]=],
requireKeywords = {
"SetFrameBackdropColor",
"function",
"SetBackdropColor",
"math.max",
"math.min",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.SetFrameBackdropColor) ~= "function" then
_G.checkError = "SetFrameBackdropColor не является глобальной функцией"
return false
end
local testFrame = CreateFrame("Frame", nil, UIParent)
testFrame:SetSize(80, 80)
testFrame:SetBackdrop({
bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
tile = true, tileSize = 16, edgeSize = 16,
insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
local ok1, result1 = pcall(_G.SetFrameBackdropColor, testFrame, 0.5, 0.3, 0.1, 0.9)
if not ok1 then
_G.checkError = "Ошибка вызова SetFrameBackdropColor: " .. tostring(result1)
return false
end
if result1 ~= true then
_G.checkError = "Для корректных данных функция должна вернуть true"
return false
end
local ok2, result2 = pcall(_G.SetFrameBackdropColor, nil, 0, 0, 0, 1)
if not ok2 or result2 ~= false then
_G.checkError = "Для nil-фрейма функция должна вернуть false"
return false
end
local ok3, result3 = pcall(_G.SetFrameBackdropColor, testFrame, 2, 0, 0, 1)
if not ok3 then
_G.checkError = "Ошибка при r > 1: " .. tostring(result3)
return false
end
if result3 ~= true then
_G.checkError = "Для r > 1 функция должна вернуть true (с клампом)"
return false
end
return true
end,
}

ns_llua['lua'][262] = {
type = "commenttest",
title = "Тест 262: функция CreateStyledPanel",
helpModules = {257, 215, 221, 227, 45, 65},
preloadVars = {
{var = "CreateStyledPanel", desc = "CreateStyledPanel очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 233-5: функция CreateStyledPanel</h>
<t>Создай глобальную функцию <k>CreateStyledPanel(name, width, height, title)</k>.</t>
<t>Требования:</t>
<t>- если <k>name</k> не строка или пустая, верни <k>nil</k>;</t>
<t>- если <k>width</k> или <k>height</k> не числа или меньше 50, верни <k>nil</k>;</t>
<t>- если <k>title</k> не строка, используй пустую строку;</t>
<t>- создай фрейм типа <s>"Frame"</s> с именем <k>name</k>, родитель <k>UIParent</k>;</t>
<t>- размер: <k>width</k> на <k>height</k>;</t>
<t>- позиция: CENTER;</t>
<t>- примени backdrop с bgFile и edgeFile из Tooltips;</t>
<t>- цвет фона: чёрный полупрозрачный (0, 0, 0, 0.85);</t>
<t>- цвет рамки: серый (0.5, 0.5, 0.5, 1);</t>
<t>- создай FontString заголовок слоем OVERLAY, шаблон GameFontNormalLarge;</t>
<t>- позиция заголовка: TOP, смещение 0, -10;</t>
<t>- текст заголовка: <k>title</k>;</t>
<t>- покажи фрейм;</t>
<t>- верни фрейм.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateStyledPanel(name, width, height, title)
]=],
requireKeywords = {
"CreateStyledPanel",
"function",
"CreateFrame",
"SetBackdrop",
"SetBackdropColor",
"CreateFontString",
"SetText",
"Show",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateStyledPanel) ~= "function" then
_G.checkError = "CreateStyledPanel не является глобальной функцией"
return false
end
local ok1, f1 = pcall(_G.CreateStyledPanel, "NS_Test_Panel_1", 200, 150, "Заголовок")
if not ok1 then
_G.checkError = "Ошибка вызова CreateStyledPanel: " .. tostring(f1)
return false
end
if not f1 or type(f1.IsShown) ~= "function" then
_G.checkError = "Функция должна вернуть фрейм"
return false
end
if not f1:IsShown() then
_G.checkError = "Фрейм должен быть показан"
return false
end
if f1:GetWidth() ~= 200 or f1:GetHeight() ~= 150 then
_G.checkError = "Размер фрейма должен быть 200 на 150"
return false
end
local bd = f1:GetBackdrop()
if type(bd) ~= "table" or type(bd.bgFile) ~= "string" then
_G.checkError = "Backdrop должен быть применён"
return false
end
local ok2, f2 = pcall(_G.CreateStyledPanel, "", 200, 150, "Тест")
if not ok2 or f2 ~= nil then
_G.checkError = "Для пустого имени функция должна вернуть nil"
return false
end
local ok3, f3 = pcall(_G.CreateStyledPanel, "NS_Test_Panel_2", 30, 150, "Тест")
if not ok3 or f3 ~= nil then
_G.checkError = "Для width < 50 функция должна вернуть nil"
return false
end
return true
end,
}

ns_llua['lua'][263] = {
type = "info",
title = "Тултипы: GameTooltip и подсказки",
helpModules = {215, 227, 233},
content = [=[
<h>Тултипы: GameTooltip и подсказки</h>
<t>Тултип — это всплывающая подсказка, которая появляется при наведении курсора на элемент интерфейса. В WoW 3.3.5 есть глобальный объект <k>GameTooltip</k>, который можно использовать для показа информации.</t>
<h>Основные методы GameTooltip</h>
<c>GameTooltip:SetOwner(frame, anchor)</c> — привязать тултип к фрейму.
<c>GameTooltip:SetText(text)</c> — установить основной текст.
<c>GameTooltip:AddLine(text, r, g, b)</c> — добавить строку.
<c>GameTooltip:AddDoubleLine(left, right)</c> — добавить строку с двумя колонками.
<c>GameTooltip:Show()</c> — показать тултип.
<c>GameTooltip:Hide()</c> — скрыть тултип.
<h>SetOwner</h>
<t>Перед показом тултипа нужно указать, к какому фрейму он привязан:</t>
<code>
GameTooltip:SetOwner(MyFrame, "ANCHOR_TOPRIGHT")
</code>
<t>Варианты привязки:</t>
<c>"ANCHOR_TOP"</c> — над фреймом.
<c>"ANCHOR_BOTTOM"</c> — под фреймом.
<c>"ANCHOR_LEFT"</c> — слева.
<c>"ANCHOR_RIGHT"</c> — справа.
<c>"ANCHOR_TOPRIGHT"</c> — в правом верхнем углу.
<c>"ANCHOR_CURSOR"</c> — у курсора мыши.
<h>OnEnter и OnLeave</h>
<t>Тултипы показываются при наведении мыши. Для этого используются скрипты <k>OnEnter</k> и <k>OnLeave</k>:</t>
<code>
MyFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
    GameTooltip:SetText("Мой фрейм")
    GameTooltip:AddLine("Описание фрейма", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end)
MyFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
</code>
<h>Показ предмета через SetHyperlink</h>
<t>Чтобы показать стандартный тултип предмета:</t>
<code>
GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
GameTooltip:SetHyperlink("item:6948:0:0:0:0:0:0:0")
GameTooltip:Show()
</code>
<t>Или через ссылку:</t>
<code>
local _, link = GetItemInfo(6948)
if link then
    GameTooltip:SetHyperlink(link)
end
</code>
<h>Показ заклинания</h>
<code>
GameTooltip:SetSpellByID(6603)
</code>
<h>AddLine с цветом</h>
<code>
GameTooltip:AddLine("Красный текст", 1, 0, 0)
GameTooltip:AddLine("Зелёный текст", 0, 1, 0)
GameTooltip:AddLine("Белый текст", 1, 1, 1)
</code>
<h>AddDoubleLine</h>
<code>
GameTooltip:AddDoubleLine("Слева", "Справа", 1, 1, 1, 0.8, 0.8, 0.8)
</code>
<h>GameTooltip_SetDefaultAnchor</h>
<t>Стандартная функция для привязки тултипа к курсору:</t>
<code>
GameTooltip_SetDefaultAnchor(GameTooltip, self)
</code>
<t>Это эквивалент <k>GameTooltip:SetOwner(self, "ANCHOR_CURSOR")</k>.</t>
<h>Важные правила</h>
<w>Правило 1:</w> всегда вызывай <k>GameTooltip:Hide()</k> в OnLeave. Иначе тултип останется на экране.
<w>Правило 2:</w> перед AddLine вызови SetText или SetOwner. Иначе тултип может быть пустым.
<w>Правило 3:</w> не показывай тултип в бою, если он может блокировать обзор.
]=],
}

ns_llua['lua'][264] = {
type = "vartest",
title = "Тест 264: константы тултипов",
helpModules = {263},
tasks = {
{
var = "tooltipAnchorTop",
desc = 'Создай глобальную переменную tooltipAnchorTop = "ANCHOR_TOP"',
check = function(value)
return value == "ANCHOR_TOP"
end,
},
{
var = "tooltipAnchorCursor",
desc = 'Создай глобальную переменную tooltipAnchorCursor = "ANCHOR_CURSOR"',
check = function(value)
return value == "ANCHOR_CURSOR"
end,
},
{
var = "tooltipExists",
desc = 'Создай глобальную переменную tooltipExists = (type(GameTooltip) ~= "nil")',
check = function(value)
return value == true
end,
},
},
}

ns_llua['lua'][265] = {
type = "commenttest",
title = "Тест 265: фрейм с тултипом",
helpModules = {263, 215, 221},
preloadVars = {
{var = "CourseTooltipFrame", desc = "CourseTooltipFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 239-2: фрейм с тултипом</h>
<t>Создай глобальный фрейм <k>CourseTooltipFrame</k>.</t>
<t>Требования:</t>
<t>- тип: <s>"Frame"</s>, глобальное имя: <s>"CourseTooltipFrame"</s>, родитель: <k>UIParent</k>;</t>
<t>- размер: 150 на 100;</t>
<t>- позиция: CENTER;</t>
<t>- включи мышку через <k>EnableMouse(true)</k>;</t>
<t>- назначь скрипт <k>OnEnter</k>, который:</t>
<c>вызывает GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")</c>
<c>вызывает GameTooltip:SetText("Тестовый фрейм")</c>
<c>вызывает GameTooltip:AddLine("Наведи и прочитай", 0.8, 0.8, 0.8)</c>
<c>вызывает GameTooltip:Show()</c>
<t>- назначь скрипт <k>OnLeave</k>, который вызывает <k>GameTooltip:Hide()</k>;</t>
<t>- покажи фрейм.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм CourseTooltipFrame с тултипом
]=],
requireKeywords = {
"CourseTooltipFrame",
"CreateFrame",
"EnableMouse",
"SetScript",
"OnEnter",
"OnLeave",
"GameTooltip",
"SetOwner",
"SetText",
"AddLine",
"Show",
"Hide",
},
checkCode = function()
_G.checkError = nil
local f = _G.CourseTooltipFrame
if not f or type(f.GetScript) ~= "function" then
_G.checkError = "CourseTooltipFrame не является фреймом"
return false
end
if not f:IsShown() then
_G.checkError = "Фрейм должен быть показан"
return false
end
if f:GetWidth() ~= 150 or f:GetHeight() ~= 100 then
_G.checkError = "Размер фрейма должен быть 150 на 100"
return false
end
local onEnter = f:GetScript("OnEnter")
if type(onEnter) ~= "function" then
_G.checkError = "У фрейма должен быть обработчик OnEnter"
return false
end
local onLeave = f:GetScript("OnLeave")
if type(onLeave) ~= "function" then
_G.checkError = "У фрейма должен быть обработчик OnLeave"
return false
end
return true
end,
}

ns_llua['lua'][266] = {
type = "commenttest",
title = "Тест 266: функция ShowItemTooltip",
helpModules = {263, 179, 45, 65},
preloadVars = {
{var = "ShowItemTooltip", desc = "ShowItemTooltip очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 239-3: функция ShowItemTooltip</h>
<t>Создай глобальную функцию <k>ShowItemTooltip(frame, itemID)</k>.</t>
<t>Требования:</t>
<t>- если <k>frame</k> не существует или у него нет метода <k>GetScript</k>, верни <k>false</k>;</t>
<t>- если <k>itemID</k> не является числом или меньше либо равно нуля, верни <k>false</k>;</t>
<t>- иначе назначь скрипт <k>OnEnter</k> на фрейм, который:</t>
<c>вызывает GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")</c>
<c>вызывает GameTooltip:SetHyperlink("item:" .. itemID)</c>
<c>вызывает GameTooltip:Show()</c>
<t>- назначь скрипт <k>OnLeave</k>, который вызывает <k>GameTooltip:Hide()</k>;</t>
<t>- верни <k>true</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию ShowItemTooltip(frame, itemID)
]=],
requireKeywords = {
"ShowItemTooltip",
"function",
"GameTooltip",
"SetOwner",
"SetHyperlink",
"OnEnter",
"OnLeave",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.ShowItemTooltip) ~= "function" then
_G.checkError = "ShowItemTooltip не является глобальной функцией"
return false
end
local testFrame = CreateFrame("Frame", nil, UIParent)
testFrame:SetSize(64, 64)
local ok1, result1 = pcall(_G.ShowItemTooltip, testFrame, 6948)
if not ok1 then
_G.checkError = "Ошибка вызова ShowItemTooltip: " .. tostring(result1)
return false
end
if result1 ~= true then
_G.checkError = "Для корректных данных функция должна вернуть true"
return false
end
local onEnter = testFrame:GetScript("OnEnter")
if type(onEnter) ~= "function" then
_G.checkError = "OnEnter должен быть назначен"
return false
end
local onLeave = testFrame:GetScript("OnLeave")
if type(onLeave) ~= "function" then
_G.checkError = "OnLeave должен быть назначен"
return false
end
local ok2, result2 = pcall(_G.ShowItemTooltip, nil, 6948)
if not ok2 or result2 ~= false then
_G.checkError = "Для nil-фрейма функция должна вернуть false"
return false
end
local ok3, result3 = pcall(_G.ShowItemTooltip, testFrame, -1)
if not ok3 or result3 ~= false then
_G.checkError = "Для отрицательного itemID функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][267] = {
type = "commenttest",
title = "Тест 267: функция ShowCustomTooltip",
helpModules = {263, 45, 65},
preloadVars = {
{var = "ShowCustomTooltip", desc = "ShowCustomTooltip очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 239-4: функция ShowCustomTooltip</h>
<t>Создай глобальную функцию <k>ShowCustomTooltip(frame, title, lines)</k>.</t>
<t>Аргументы:</t>
<c>frame</c> — фрейм-владелец.
<c>title</c> — строка-заголовок.
<c>lines</c> — таблица-массив со строками для дополнительных линий.
<t>Требования:</t>
<t>- если <k>frame</k> не существует, верни <k>false</k>;</t>
<t>- если <k>title</k> не строка, используй пустую строку;</t>
<t>- если <k>lines</k> не таблица, используй пустую таблицу;</t>
<t>- назначь OnEnter на фрейм, который:</t>
<c>GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT")</c>
<c>GameTooltip:SetText(title, 1, 0.84, 0)</c>
<c>для каждой строки из lines: GameTooltip:AddLine(line, 0.8, 0.8, 0.8)</c>
<c>GameTooltip:Show()</c>
<t>- назначь OnLeave с GameTooltip:Hide();</t>
<t>- верни <k>true</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию ShowCustomTooltip(frame, title, lines)
]=],
requireKeywords = {
"ShowCustomTooltip",
"function",
"GameTooltip",
"SetOwner",
"SetText",
"AddLine",
"OnEnter",
"OnLeave",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.ShowCustomTooltip) ~= "function" then
_G.checkError = "ShowCustomTooltip не является глобальной функцией"
return false
end
local testFrame = CreateFrame("Frame", nil, UIParent)
testFrame:SetSize(100, 100)
local ok1, result1 = pcall(_G.ShowCustomTooltip, testFrame, "Заголовок", {"Строка 1", "Строка 2"})
if not ok1 then
_G.checkError = "Ошибка вызова ShowCustomTooltip: " .. tostring(result1)
return false
end
if result1 ~= true then
_G.checkError = "Для корректных данных функция должна вернуть true"
return false
end
local onEnter = testFrame:GetScript("OnEnter")
if type(onEnter) ~= "function" then
_G.checkError = "OnEnter должен быть назначен"
return false
end
local ok2, result2 = pcall(_G.ShowCustomTooltip, nil, "Тест", {})
if not ok2 or result2 ~= false then
_G.checkError = "Для nil-фрейма функция должна вернуть false"
return false
end
local ok3, result3 = pcall(_G.ShowCustomTooltip, testFrame, nil, nil)
if not ok3 or result3 ~= true then
_G.checkError = "Для nil-title и nil-lines функция должна вернуть true (с дефолтами)"
return false
end
return true
end,
}

ns_llua['lua'][268] = {
type = "commenttest",
title = "Тест 268: функция CreateTooltipButton",
helpModules = {263, 233, 215, 45, 65},
preloadVars = {
{var = "CreateTooltipButton", desc = "CreateTooltipButton очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 239-5: функция CreateTooltipButton</h>
<t>Создай глобальную функцию <k>CreateTooltipButton(name, text, tooltipText)</k>.</t>
<t>Требования:</t>
<t>- если <k>name</k> не строка или пустая, верни <k>nil</k>;</t>
<t>- если <k>text</k> не строка, используй <s>"Кнопка"</s>;</t>
<t>- если <k>tooltipText</k> не строка, используй пустую строку;</t>
<t>- создай кнопку типа <s>"Button"</s> с именем <k>name</k>, родитель <k>UIParent</k>;</t>
<t>- размер: 140 на 35;</t>
<t>- позиция: CENTER;</t>
<t>- создай FontString для кнопки с текстом <k>text</k>;</t>
<t>- назначь OnEnter: GameTooltip:SetOwner, SetText(tooltipText), Show;</t>
<t>- назначь OnLeave: GameTooltip:Hide();</t>
<t>- покажи кнопку;</t>
<t>- верни кнопку.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateTooltipButton(name, text, tooltipText)
]=],
requireKeywords = {
"CreateTooltipButton",
"function",
"CreateFrame",
"Button",
"CreateFontString",
"SetText",
"OnEnter",
"OnLeave",
"GameTooltip",
"Show",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateTooltipButton) ~= "function" then
_G.checkError = "CreateTooltipButton не является глобальной функцией"
return false
end
local ok1, btn = pcall(_G.CreateTooltipButton, "NS_TT_Btn_1", "Нажми", "Подсказка")
if not ok1 then
_G.checkError = "Ошибка вызова CreateTooltipButton: " .. tostring(btn)
return false
end
if not btn or type(btn.GetScript) ~= "function" then
_G.checkError = "Функция должна вернуть кнопку"
return false
end
if not btn:IsShown() then
_G.checkError = "Кнопка должна быть показана"
return false
end
local onEnter = btn:GetScript("OnEnter")
if type(onEnter) ~= "function" then
_G.checkError = "У кнопки должен быть OnEnter"
return false
end
local onLeave = btn:GetScript("OnLeave")
if type(onLeave) ~= "function" then
_G.checkError = "У кнопки должен быть OnLeave"
return false
end
local ok2, result2 = pcall(_G.CreateTooltipButton, "", "Текст", "Тултип")
if not ok2 or result2 ~= nil then
_G.checkError = "Для пустого имени функция должна вернуть nil"
return false
end
return true
end,
}

ns_llua['lua'][269] = {
type = "info",
title = "Слэш-команды: SlashCmdList",
helpModules = {239, 215},
content = [=[
<h>Слэш-команды: SlashCmdList</h>
<t>Слэш-команды позволяют игроку управлять аддоном через чат. Например, <k>/panel show</k> или <k>/panel reset</k>.</t>
<h>Как это работает</h>
<t>WoW использует две вещи для регистрации команды:</t>
<c>1</c> — глобальная переменная <k>SLASH_ИМЯ1</k> содержит текст команды.
<c>2</c> — таблица <k>SlashCmdList["ИМЯ"]</k> содержит функцию-обработчик.
<h>Простой пример</h>
<code>
SLASH_MYADDON1 = "/myaddon"
SlashCmdList["MYADDON"] = function(msg)
    print("Вы ввели: " .. msg)
end
</code>
<t>После этого в чате можно написать:</t>
<code>
/myaddon hello
</code>
<t>И в чат выведется: <s>"Вы ввели: hello"</s></t>
<h>Несколько алиасов</h>
<t>Можно зарегистрировать несколько вариантов команды:</t>
<code>
SLASH_MYADDON1 = "/myaddon"
SLASH_MYADDON2 = "/ma"
SlashCmdList["MYADDON"] = function(msg)
    print("Команда вызвана с: " .. msg)
end
</code>
<t>Теперь работают и <k>/myaddon</k>, и <k>/ma</k>.</t>
<h>Аргумент msg</h>
<t>Аргумент <k>msg</k> — это всё, что игрок написал после команды. Если написать <k>/myaddon show all</k>, то <k>msg</k> будет равен <s>"show all"</s>.</t>
<h>Разбиение аргументов</h>
<code>
SLASH_MYADDON1 = "/myaddon"
SlashCmdList["MYADDON"] = function(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word)
    end
    local cmd = args[1] or ""
    if cmd == "show" then
        print("Показываю")
    elseif cmd == "hide" then
        print("Скрываю")
    elseif cmd == "reset" then
        print("Сбрасываю")
    else
        print("Неизвестная команда: " .. cmd)
    end
end
</code>
<h>Типичные подкоманды</h>
<c>show</c> — показать фрейм.
<c>hide</c> — скрыть фрейм.
<c>toggle</c> — переключить видимость.
<c>reset</c> — сбросить позицию или настройки.
<c>config</c> — открыть настройки.
<c>help</c> — показать список команд.
<h>Безопасный шаблон</h>
<code>
SLASH_NSPANEL1 = "/nspanel"
SLASH_NSPANEL2 = "/nsp"
SlashCmdList["NSPANEL"] = function(msg)
    msg = msg or ""
    msg = msg:lower()
    msg = msg:gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "" or msg == "help" then
        print("/nspanel show|hide|toggle|reset")
    elseif msg == "show" then
        -- показать
    elseif msg == "hide" then
        -- скрыть
    elseif msg == "toggle" then
        -- переключить
    elseif msg == "reset" then
        -- сбросить
    else
        print("Неизвестная подкоманда: " .. msg)
    end
end
</code>
<h>Частые ошибки</h>
<w>Ошибка 1:</w> имя в SlashCmdList должно совпадать с суффиксом SLASH_ИМЯ. Если переменная <k>SLASH_MYADDON1</k>, то ключ в SlashCmdList — <s>"MYADDON"</s>.
<w>Ошибка 2:</w> забыть привести msg к нижнему регистру. Игрок может написать <k>/panel SHOW</k>.
<w>Ошибка 3:</w> не обрабатывать пустой msg. Игрок может написать просто <k>/panel</k> без аргументов.
]=],
}

ns_llua['lua'][270] = {
type = "vartest",
title = "Тест 270: структура слэш-команд",
helpModules = {269},
tasks = {
{
var = "slashCmdPrefix",
desc = 'Создай глобальную переменную slashCmdPrefix = "SLASH_"',
check = function(value)
return value == "SLASH_"
end,
},
{
var = "slashCmdListType",
desc = 'Создай глобальную переменную slashCmdListType = type(SlashCmdList)',
check = function(value)
return value == "table"
end,
},
{
var = "slashCmdTest",
desc = 'Создай глобальную переменную slashCmdTest = "/testcmd"',
check = function(value)
return value == "/testcmd"
end,
},
},
}

ns_llua['lua'][271] = {
type = "commenttest",
title = "Тест 271: регистрация слэш-команды",
helpModules = {269, 45},
preloadVars = {
{var = "nsSlashTestLog", desc = "nsSlashTestLog очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError", "nsSlashTestLog"},
instruction = [=[
<h>Тест 245-2: регистрация слэш-команды</h>
<t>Зарегистрируй слэш-команду:</t>
<t>- создай глобальную переменную <k>nsSlashTestLog</k> со значением <s>""</s>;</t>
<t>- создай глобальную переменную <k>SLASH_NSTEST1</k> со значением <s>"/nstest"</s>;</t>
<t>- создай обработчик в <k>SlashCmdList["NSTEST"]</k>;</t>
<t>- обработчик должен записывать аргумент <k>msg</k> в <k>nsSlashTestLog</k>;</t>
<t>- если <k>msg</k> равен <k>nil</k>, запиши пустую строку.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Зарегистрируй слэш-команду /nstest
]=],
requireKeywords = {
"SLASH_NSTEST1",
"SlashCmdList",
"NSTEST",
"function",
"nsSlashTestLog",
},
checkCode = function()
_G.checkError = nil
if _G.SLASH_NSTEST1 ~= "/nstest" then
_G.checkError = "SLASH_NSTEST1 должна быть '/nstest'"
return false
end
local handler = SlashCmdList["NSTEST"]
if type(handler) ~= "function" then
_G.checkError = "SlashCmdList['NSTEST'] должна быть функцией"
return false
end
_G.nsSlashTestLog = nil
local ok, err = pcall(handler, "hello world")
if not ok then
_G.checkError = "Ошибка вызова обработчика: " .. tostring(err)
return false
end
if _G.nsSlashTestLog ~= "hello world" then
_G.checkError = "Обработчик должен записать msg в nsSlashTestLog"
return false
end
_G.nsSlashTestLog = nil
local ok2, err2 = pcall(handler, nil)
if not ok2 then
_G.checkError = "Ошибка вызова обработчика с nil: " .. tostring(err2)
return false
end
if _G.nsSlashTestLog ~= "" then
_G.checkError = "Для nil msg обработчик должен записать пустую строку"
return false
end
return true
end,
}

ns_llua['lua'][272] = {
type = "commenttest",
title = "Тест 272: функция ParseSlashArgs",
helpModules = {269, 45, 31, 44},
preloadVars = {
{var = "ParseSlashArgs", desc = "ParseSlashArgs очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 245-3: функция ParseSlashArgs</h>
<t>Создай глобальную функцию <k>ParseSlashArgs(msg)</k>.</t>
<t>Требования:</t>
<t>- если <k>msg</k> не строка, верни пустую таблицу <k>{}</k>;</t>
<t>- иначе разбей строку по пробелам и верни таблицу-массив со словами;</t>
<t>- пустые строки и лишние пробелы должны игнорироваться;</t>
<t>- все слова должны быть в нижнем регистре через <k>string.lower</k>;</t>
<t>- используй <k>string.gmatch</k> с паттерном <s>"%S+"</s>;</t>
<t>- используй <k>table.insert</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию ParseSlashArgs(msg)
]=],
requireKeywords = {
"ParseSlashArgs",
"function",
"string.gmatch",
"string.lower",
"table.insert",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.ParseSlashArgs) ~= "function" then
_G.checkError = "ParseSlashArgs не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.ParseSlashArgs, "show all")
if not ok1 then
_G.checkError = "Ошибка вызова ParseSlashArgs: " .. tostring(result1)
return false
end
if type(result1) ~= "table" or #result1 ~= 2 then
_G.checkError = "Для 'show all' функция должна вернуть таблицу из 2 элементов"
return false
end
if result1[1] ~= "show" or result1[2] ~= "all" then
_G.checkError = "Элементы таблицы неверны"
return false
end
local ok2, result2 = pcall(_G.ParseSlashArgs, "  SHOW   ALL  ")
if not ok2 or type(result2) ~= "table" or #result2 ~= 2 then
_G.checkError = "Лишние пробелы должны игнорироваться"
return false
end
if result2[1] ~= "show" or result2[2] ~= "all" then
_G.checkError = "Слова должны быть в нижнем регистре"
return false
end
local ok3, result3 = pcall(_G.ParseSlashArgs, "")
if not ok3 or type(result3) ~= "table" or #result3 ~= 0 then
_G.checkError = "Для пустой строки функция должна вернуть пустую таблицу"
return false
end
local ok4, result4 = pcall(_G.ParseSlashArgs, 123)
if not ok4 or type(result4) ~= "table" or #result4 ~= 0 then
_G.checkError = "Для не-строки функция должна вернуть пустую таблицу"
return false
end
return true
end,
}

ns_llua['lua'][273] = {
type = "commenttest",
title = "Тест 273: функция HandlePanelCommand",
helpModules = {269, 45, 17, 19},
preloadVars = {
{var = "HandlePanelCommand", desc = "HandlePanelCommand очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 245-4: функция HandlePanelCommand</h>
<t>Создай глобальную функцию <k>HandlePanelCommand(msg)</k>.</t>
<t>Требования:</t>
<t>- если <k>msg</k> не строка, верни строку <s>"invalid"</s>;</t>
<t>- приведи msg к нижнему регистру и убери пробелы по краям;</t>
<t>- если msg пустой или равен <s>"help"</s>, верни <s>"help"</s>;</t>
<t>- если msg равен <s>"show"</s>, верни <s>"show"</s>;</t>
<t>- если msg равен <s>"hide"</s>, верни <s>"hide"</s>;</t>
<t>- если msg равен <s>"toggle"</s>, верни <s>"toggle"</s>;</t>
<t>- если msg равен <s>"reset"</s>, верни <s>"reset"</s>;</t>
<t>- во всех остальных случаях верни <s>"unknown"</s>.</t>
<t>Используй <k>string.lower</k>, <k>string.gsub</k> для удаления пробелов.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию HandlePanelCommand(msg)
]=],
requireKeywords = {
"HandlePanelCommand",
"function",
"string.lower",
"if",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.HandlePanelCommand) ~= "function" then
_G.checkError = "HandlePanelCommand не является глобальной функцией"
return false
end
local tests = {
{input = "show", expected = "show"},
{input = "SHOW", expected = "show"},
{input = "  show  ", expected = "show"},
{input = "hide", expected = "hide"},
{input = "toggle", expected = "toggle"},
{input = "reset", expected = "reset"},
{input = "", expected = "help"},
{input = "help", expected = "help"},
{input = "  ", expected = "help"},
{input = "badcmd", expected = "unknown"},
{input = 123, expected = "invalid"},
{input = nil, expected = "invalid"},
}
for i, test in ipairs(tests) do
local ok, result = pcall(_G.HandlePanelCommand, test.input)
if not ok or result ~= test.expected then
_G.checkError = "Тест " .. i .. " не пройден (вход: " .. tostring(test.input) .. ")"
return false
end
end
return true
end,
}

ns_llua['lua'][274] = {
type = "commenttest",
title = "Тест 274: полный обработчик слэш-команды",
helpModules = {269, 215, 45, 31},
preloadVars = {
{var = "nsSlashPanel", desc = "nsSlashPanel очищается перед проверкой"},
{var = "nsSlashPanelState", desc = "nsSlashPanelState очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError", "nsSlashPanelState"},
instruction = [=[
<h>Тест 245-5: полный обработчик слэш-команды</h>
<t>Создай:</t>
<t>1. Глобальную таблицу <k>nsSlashPanelState</k> с полем <k>visible</k> равным <k>true</k>.</t>
<t>2. Глобальный фрейм <k>nsSlashPanel</k> (Frame, 200x100, CENTER, показан).</t>
<t>3. Глобальную переменную <k>SLASH_NSPANEL1</k> = <s>"/nspanel"</s>.</t>
<t>4. Обработчик <k>SlashCmdList["NSPANEL"]</k>, который:</t>
<t>- парсит msg в нижнем регистре;</t>
<t>- если <s>"show"</s>: показывает фрейм, ставит visible = true;</t>
<t>- если <s>"hide"</s>: скрывает фрейм, ставит visible = false;</t>
<t>- если <s>"toggle"</s>: переключает видимость;</t>
<t>- если <s>"reset"</s>: SetPoint("CENTER"), visible = true, Show();</t>
<t>- иначе: ничего не делает.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай nsSlashPanelState, nsSlashPanel и обработчик /nspanel
]=],
requireKeywords = {
"nsSlashPanelState",
"nsSlashPanel",
"SLASH_NSPANEL1",
"SlashCmdList",
"NSPANEL",
"function",
"Show",
"Hide",
},
checkCode = function()
_G.checkError = nil
if type(_G.nsSlashPanelState) ~= "table" then
_G.checkError = "nsSlashPanelState должна быть таблицей"
return false
end
if _G.nsSlashPanelState.visible ~= true then
_G.checkError = "nsSlashPanelState.visible должна быть true изначально"
return false
end
local f = _G.nsSlashPanel
if not f or type(f.IsShown) ~= "function" then
_G.checkError = "nsSlashPanel не является фреймом"
return false
end
if not f:IsShown() then
_G.checkError = "nsSlashPanel должен быть показан изначально"
return false
end
if _G.SLASH_NSPANEL1 ~= "/nspanel" then
_G.checkError = "SLASH_NSPANEL1 должна быть '/nspanel'"
return false
end
local handler = SlashCmdList["NSPANEL"]
if type(handler) ~= "function" then
_G.checkError = "SlashCmdList['NSPANEL'] должна быть функцией"
return false
end
-- Тест hide
local ok1, err1 = pcall(handler, "hide")
if not ok1 then
_G.checkError = "Ошибка при вызове 'hide': " .. tostring(err1)
return false
end
if _G.nsSlashPanelState.visible ~= false then
_G.checkError = "После 'hide' visible должна быть false"
return false
end
if f:IsShown() then
_G.checkError = "После 'hide' фрейм должен быть скрыт"
return false
end
-- Тест show
local ok2, err2 = pcall(handler, "show")
if not ok2 then
_G.checkError = "Ошибка при вызове 'show': " .. tostring(err2)
return false
end
if _G.nsSlashPanelState.visible ~= true then
_G.checkError = "После 'show' visible должна быть true"
return false
end
if not f:IsShown() then
_G.checkError = "После 'show' фрейм должен быть показан"
return false
end
-- Тест toggle
local ok3, err3 = pcall(handler, "toggle")
if not ok3 then
_G.checkError = "Ошибка при вызове 'toggle': " .. tostring(err3)
return false
end
if _G.nsSlashPanelState.visible ~= false then
_G.checkError = "После 'toggle' visible должна быть false"
return false
end
return true
end,
}

ns_llua['lua'][275] = {
type = "info",
title = "Кнопка на миникарте",
helpModules = {215, 221, 227, 233, 239},
content = [=[
<h>Кнопка на миникарте</h>
<t>Многие аддоны добавляют иконку на миникарту для быстрого доступа к настройкам или переключения видимости. В WoW 3.3.5 это делается вручную через позиционирование фрейма вокруг миникарты.</t>
<h>Миникарта как ориентир</h>
<t>Глобальный фрейм <k>Minimap</k> — это миникарта. Её размер обычно 140x140 пикселей.</t>
<code>
/run print(Minimap:GetWidth(), Minimap:GetHeight())
</code>
<h>Позиционирование по кругу</h>
<t>Чтобы разместить кнопку вокруг миникарты, используют тригонометрию:</t>
<code>
local angle = math.rad(45) -- угол в радианах
local radius = 80          -- радиус от центра
local x = math.cos(angle) * radius
local y = math.sin(angle) * radius
MyMinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
</code>
<t>Угол 0 — справа, 90 — сверху, 180 — слева, 270 — снизу.</t>
<h>Создание кнопки миникарты</h>
<code>
CourseMinimapBtn = CreateFrame("Button", "CourseMinimapBtn", Minimap)
CourseMinimapBtn:SetSize(32, 32)
CourseMinimapBtn:SetFrameStrata("HIGH")
CourseMinimapBtn:SetPoint("CENTER", Minimap, "CENTER", 80, 0)
</code>
<t>Обрати внимание: родитель — <k>Minimap</k>, а не <k>UIParent</k>. Это позволяет кнопке двигаться вместе с миникартой.</t>
<h>Иконка кнопки</h>
<code>
local icon = CourseMinimapBtn:CreateTexture(nil, "BACKGROUND")
icon:SetAllPoints(CourseMinimapBtn)
icon:SetTexture("Interface\\Icons\\Spell_Frost_IceStorm")
</code>
<h>Рамка (border)</h>
<t>Стандартная круглая рамка миникарты:</t>
<code>
local border = CourseMinimapBtn:CreateTexture(nil, "OVERLAY")
border:SetSize(54, 54)
border:SetPoint("CENTER", CourseMinimapBtn, "CENTER")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
</code>
<h>Перетаскивание по кругу миникарты</h>
<t>Чтобы кнопка двигалась только по окружности вокруг миникарты:</t>
<code>
CourseMinimapBtn:RegisterForDrag("LeftButton")
CourseMinimapBtn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function(self)
        local cx, cy = Minimap:GetCenter()
        local mx, my = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        mx = mx / scale
        my = my / scale
        local angle = math.atan2(my - cy, mx - cx)
        local radius = 80
        local x = math.cos(angle) * radius
        local y = math.sin(angle) * radius
        self:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end)
end)
CourseMinimapBtn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)
</code>
<h>math.atan2</h>
<code>
/run print(math.atan2(1, 0))  -- pi/2 (90 градусов)
/run print(math.atan2(0, 1))  -- 0 (0 градусов)
</code>
<t>Функция <k>math.atan2(y, x)</k> возвращает угол в радианах от -pi до pi.</t>
<h>GetCursorPosition</h>
<t>Возвращает позицию курсора в пикселях экрана. Нужно делить на <k>GetEffectiveScale()</k> фрейма, чтобы получить координаты в масштабе фрейма.</t>
<h>Сохранение позиции</h>
<t>Угол кнопки удобно сохранять в SavedVariables:</t>
<code>
MyAddonDB = MyAddonDB or {}
MyAddonDB.minimapAngle = MyAddonDB.minimapAngle or 0
</code>
<t>При загрузке аддона восстанавливаем позицию:</t>
<code>
local angle = MyAddonDB.minimapAngle
local x = math.cos(angle) * 80
local y = math.sin(angle) * 80
CourseMinimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
</code>
<h>Частые ошибки</h>
<w>Ошибка 1:</w> родитель UIParent вместо Minimap. Кнопка не будет двигаться с миникартой.
<w>Ошибка 2:</w> забыть GetEffectiveScale при работе с GetCursorPosition.
<w>Ошибка 3:</w> не снять OnUpdate в OnDragStop. Кнопка продолжит двигаться после отпускания мыши.
]=],
}

ns_llua['lua'][276] = {
type = "vartest",
title = "Тест: тригонометрия для миникарты",
helpModules = {275, 10},
tasks = {
{
var = "minimapRadius",
desc = 'Создай глобальную переменную minimapRadius = 80',
check = function(value)
return type(value) == "number" and value == 80
end,
},
{
var = "angleRight",
desc = 'Создай глобальную переменную angleRight = 0 (угол в радианах для позиции справа)',
check = function(value)
return type(value) == "number" and value == 0
end,
},
{
var = "posXRight",
desc = 'Создай глобальную переменную posXRight = math.cos(0) * 80',
check = function(value)
return type(value) == "number" and math.abs(value - 80) < 0.01
end,
},
{
var = "posYRight",
desc = 'Создай глобальную переменную posYRight = math.sin(0) * 80',
check = function(value)
return type(value) == "number" and math.abs(value) < 0.01
end,
},
},
}

ns_llua['lua'][277] = {
type = "commenttest",
title = "Тест: кнопка на миникарте",
helpModules = {275, 215, 227},
preloadVars = {
{var = "CourseMinimapButton", desc = "CourseMinimapButton очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 251-2: кнопка на миникарте</h>
<t>Создай глобальную кнопку <k>CourseMinimapButton</k>.</t>
<t>Требования:</t>
<t>- тип: <s>"Button"</s>, глобальное имя: <s>"CourseMinimapButton"</s>;</t>
<t>- родитель: <k>Minimap</k>;</t>
<t>- размер: 32 на 32;</t>
<t>- слой: <k>SetFrameStrata("HIGH")</k>;</t>
<t>- позиция: <k>SetPoint("CENTER", Minimap, "CENTER", 80, 0)</k>;</t>
<t>- создай текстуру слоем BACKGROUND, растяни через SetAllPoints;</t>
<t>- установи текстуру: <s>"Interface\\Icons\\Spell_Frost_IceStorm"</s>;</t>
<t>- включи мышку через EnableMouse(true);</t>
<t>- покажи кнопку.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную кнопку CourseMinimapButton на миникарте
]=],
requireKeywords = {
"CourseMinimapButton",
"CreateFrame",
"Button",
"Minimap",
"SetSize",
"SetPoint",
"SetFrameStrata",
"CreateTexture",
"SetTexture",
"EnableMouse",
"Show",
},
checkCode = function()
_G.checkError = nil
local btn = _G.CourseMinimapButton
if not btn or type(btn.GetScript) ~= "function" then
_G.checkError = "CourseMinimapButton не является кнопкой"
return false
end
if not btn:IsShown() then
_G.checkError = "Кнопка должна быть показана"
return false
end
if btn:GetWidth() ~= 32 or btn:GetHeight() ~= 32 then
_G.checkError = "Размер кнопки должен быть 32 на 32"
return false
end
if btn:GetParent() ~= Minimap then
_G.checkError = "Родитель кнопки должен быть Minimap"
return false
end
return true
end,
}

ns_llua['lua'][278] = {
type = "commenttest",
title = "Тест: функция PositionOnMinimap",
helpModules = {275, 45, 10, 65},
preloadVars = {
{var = "PositionOnMinimap", desc = "PositionOnMinimap очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 251-3: функция PositionOnMinimap</h>
<t>Создай глобальную функцию <k>PositionOnMinimap(frame, angleDegrees, radius)</k>.</t>
<t>Требования:</t>
<t>- если <k>frame</k> не существует или у него нет метода <k>SetPoint</k>, верни <k>false</k>;</t>
<t>- если <k>angleDegrees</k> не число, верни <k>false</k>;</t>
<t>- если <k>radius</k> не число или меньше 10, верни <k>false</k>;</t>
<t>- иначе переведи градусы в радианы: <k>math.rad(angleDegrees)</k>;</t>
<t>- вычисли x = math.cos(radians) * radius;</t>
<t>- вычисли y = math.sin(radians) * radius;</t>
<t>- вызови <k>frame:SetPoint("CENTER", Minimap, "CENTER", x, y)</k>;</t>
<t>- верни <k>true</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию PositionOnMinimap(frame, angleDegrees, radius)
]=],
requireKeywords = {
"PositionOnMinimap",
"function",
"math.rad",
"math.cos",
"math.sin",
"SetPoint",
"Minimap",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.PositionOnMinimap) ~= "function" then
_G.checkError = "PositionOnMinimap не является глобальной функцией"
return false
end
local testFrame = CreateFrame("Frame", nil, Minimap)
testFrame:SetSize(32, 32)
local ok1, result1 = pcall(_G.PositionOnMinimap, testFrame, 45, 80)
if not ok1 then
_G.checkError = "Ошибка вызова PositionOnMinimap: " .. tostring(result1)
return false
end
if result1 ~= true then
_G.checkError = "Для корректных данных функция должна вернуть true"
return false
end
local ok2, result2 = pcall(_G.PositionOnMinimap, nil, 45, 80)
if not ok2 or result2 ~= false then
_G.checkError = "Для nil-фрейма функция должна вернуть false"
return false
end
local ok3, result3 = pcall(_G.PositionOnMinimap, testFrame, "bad", 80)
if not ok3 or result3 ~= false then
_G.checkError = "Для нечислового угла функция должна вернуть false"
return false
end
local ok4, result4 = pcall(_G.PositionOnMinimap, testFrame, 45, 5)
if not ok4 or result4 ~= false then
_G.checkError = "Для radius < 10 функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][279] = {
type = "commenttest",
title = "Тест: функция CreateMinimapButton",
helpModules = {275, 215, 227, 233, 45, 65},
preloadVars = {
{var = "CreateMinimapButton", desc = "CreateMinimapButton очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 251-4: функция CreateMinimapButton</h>
<t>Создай глобальную функцию <k>CreateMinimapButton(name, texturePath, angle)</k>.</t>
<t>Требования:</t>
<t>- если <k>name</k> не строка или пустая, верни <k>nil</k>;</t>
<t>- если <k>texturePath</k> не строка или пустая, верни <k>nil</k>;</t>
<t>- если <k>angle</k> не число, используй <n>0</n>;</t>
<t>- создай кнопку типа <s>"Button"</s> с именем <k>name</k>, родитель <k>Minimap</k>;</t>
<t>- размер: 32 на 32;</t>
<t>- слой: HIGH;</t>
<t>- создай текстуру BACKGROUND, SetAllPoints, SetTexture(texturePath);</t>
<t>- создай текстуру OVERLAY для рамки: размер 54x54, CENTER, текстура <s>"Interface\\Minimap\\MiniMap-TrackingBorder"</s>;</t>
<t>- вычисли позицию: x = cos(rad(angle)) * 80, y = sin(rad(angle)) * 80;</t>
<t>- SetPoint("CENTER", Minimap, "CENTER", x, y);</t>
<t>- EnableMouse(true);</t>
<t>- покажи кнопку;</t>
<t>- верни кнопку.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CreateMinimapButton(name, texturePath, angle)
]=],
requireKeywords = {
"CreateMinimapButton",
"function",
"CreateFrame",
"Button",
"Minimap",
"CreateTexture",
"SetTexture",
"math.cos",
"math.sin",
"math.rad",
"SetPoint",
"Show",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CreateMinimapButton) ~= "function" then
_G.checkError = "CreateMinimapButton не является глобальной функцией"
return false
end
local ok1, btn = pcall(_G.CreateMinimapButton, "NS_MM_Btn_1", "Interface\\Icons\\Spell_Frost_IceStorm", 45)
if not ok1 then
_G.checkError = "Ошибка вызова CreateMinimapButton: " .. tostring(btn)
return false
end
if not btn or type(btn.GetScript) ~= "function" then
_G.checkError = "Функция должна вернуть кнопку"
return false
end
if not btn:IsShown() then
_G.checkError = "Кнопка должна быть показана"
return false
end
if btn:GetParent() ~= Minimap then
_G.checkError = "Родитель должен быть Minimap"
return false
end
if btn:GetWidth() ~= 32 or btn:GetHeight() ~= 32 then
_G.checkError = "Размер кнопки должен быть 32 на 32"
return false
end
local ok2, result2 = pcall(_G.CreateMinimapButton, "", "Interface\\Icons\\Test", 0)
if not ok2 or result2 ~= nil then
_G.checkError = "Для пустого имени функция должна вернуть nil"
return false
end
local ok3, result3 = pcall(_G.CreateMinimapButton, "NS_MM_Btn_2", "", 0)
if not ok3 or result3 ~= nil then
_G.checkError = "Для пустой текстуры функция должна вернуть nil"
return false
end
return true
end,
}

ns_llua['lua'][280] = {
type = "commenttest",
title = "Тест: кнопка миникарты с перетаскиванием",
helpModules = {275, 221, 233, 45},
preloadVars = {
{var = "CourseDragMinimapBtn", desc = "CourseDragMinimapBtn очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {"checkError"},
instruction = [=[
<h>Тест 251-5: кнопка миникарты с перетаскиванием</h>
<t>Создай глобальную кнопку <k>CourseDragMinimapBtn</k>.</t>
<t>Требования:</t>
<t>- тип: <s>"Button"</s>, родитель: <k>Minimap</k>;</t>
<t>- размер: 32 на 32, слой HIGH;</t>
<t>- позиция: CENTER, Minimap, CENTER, 80, 0;</t>
<t>- текстура BACKGROUND: <s>"Interface\\Icons\\Inv_Sword_04"</s>, SetAllPoints;</t>
<t>- EnableMouse(true);</t>
<t>- RegisterForDrag("LeftButton");</t>
<t>- скрипт <k>OnDragStart</k>: назначает OnUpdate, который:</t>
<c>получает центр Minimap через GetCenter()</c>
<c>получает позицию курсора через GetCursorPosition()</c>
<c>делит на GetEffectiveScale()</c>
<c>вычисляет angle через math.atan2</c>
<c>вычисляет x, y через cos/sin с radius 80</c>
<c>вызывает SetPoint("CENTER", Minimap, "CENTER", x, y)</c>
<t>- скрипт <k>OnDragStop</k>: снимает OnUpdate через SetScript("OnUpdate", nil);</t>
<t>- покажи кнопку.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную кнопку CourseDragMinimapBtn с перетаскиванием по миникарте
]=],
requireKeywords = {
"CourseDragMinimapBtn",
"CreateFrame",
"Button",
"Minimap",
"EnableMouse",
"RegisterForDrag",
"OnDragStart",
"OnDragStop",
"OnUpdate",
"GetCenter",
"GetCursorPosition",
"GetEffectiveScale",
"math.atan2",
"math.cos",
"math.sin",
"SetPoint",
},
checkCode = function()
_G.checkError = nil
local btn = _G.CourseDragMinimapBtn
if not btn or type(btn.GetScript) ~= "function" then
_G.checkError = "CourseDragMinimapBtn не является кнопкой"
return false
end
if not btn:IsShown() then
_G.checkError = "Кнопка должна быть показана"
return false
end
if btn:GetParent() ~= Minimap then
_G.checkError = "Родитель должен быть Minimap"
return false
end
local onDragStart = btn:GetScript("OnDragStart")
if type(onDragStart) ~= "function" then
_G.checkError = "У кнопки должен быть OnDragStart"
return false
end
local onDragStop = btn:GetScript("OnDragStop")
if type(onDragStop) ~= "function" then
_G.checkError = "У кнопки должен быть OnDragStop"
return false
end
return true
end,
}

















































ns_llua['lua'][281] = {
type = "info",
title = "Таланты: вкладки и очки",
helpModules = {65, 45, 31},
content = [=[
<h>Таланты: вкладки и очки</h>
<t>Система талантов в WoW 3.3.5 позволяет настраивать специализацию персонажа. У каждого класса есть три ветки талантов.</t>
<h>GetNumTalentTabs</h>
<code>
/run print(GetNumTalentTabs())
</code>
<t>Возвращает количество вкладок талантов. Обычно это <n>3</n>.</t>
<h>GetNumTalents</h>
<code>
/run print(GetNumTalents(1))
</code>
<t>Возвращает количество талантов на указанной вкладке.</t>
<t>Аргументы:</t>
<c>1</c> — номер вкладки (1, 2 или 3).
<c>false</c> — второй аргумент, если нужно считать только доступные таланты.
<h>GetTalentInfo</h>
<code>
/run local name, rank, maxRank = GetTalentInfo(1, 1); print(name, rank, maxRank)
</code>
<t>Возвращает информацию о таланте:</t>
<c>name</c> — название таланта.
<c>rank</c> — текущий ранг.
<c>maxRank</c> — максимальный ранг.
<c>isExceptional</c> — является ли талантом исключительным.
<c>meetsPrereq</c> — выполнены ли требования.
<h>GetUnspentTalentPoints</h>
<code>
/run print(GetUnspentTalentPoints())
</code>
<t>Возвращает количество неиспользованных очков талантов.</t>
<h>GetNumTalentGroups</h>
<code>
/run print(GetNumTalentGroups())
</code>
<t>Возвращает количество наборов талантов. Обычно <n>1</n> или <n>2</n> (если куплен второй набор).</t>
<h>GetActiveTalentGroup</h>
<code>
/run print(GetActiveTalentGroup())
</code>
<t>Возвращает номер активного набора талантов: <n>1</n> или <n>2</n>.</t>
<h>Перебор талантов</h>
<code>
/run local count = GetNumTalents(1); for i = 1, count do local name, rank, maxRank = GetTalentInfo(1, i); if rank > 0 then print(name, rank .. "/" .. maxRank) end end
</code>
<h>Подсчёт вложенных очков</h>
<code>
/run local total = 0; for tab = 1, 3 do local count = GetNumTalents(tab); for i = 1, count do local _, rank = GetTalentInfo(tab, i); total = total + (rank or 0) end end; print("Всего очков: " .. total)
</code>
<w>Важно:</w> если персонаж ещё не открыл таланты или данные ещё не загружены, некоторые функции могут вернуть <k>nil</k>.
<h>Безопасный шаблон</h>
<code>
/run local points = GetUnspentTalentPoints() or 0; print("Неиспользованных очков: " .. points)
</code>
]=],
}

ns_llua['lua'][282] = {
type = "vartest",
title = "Тест: количество вкладок и очков",
helpModules = {281, 65},
tasks = {
{
var = "talentTabCount",
desc = 'Создай глобальную переменную talentTabCount = GetNumTalentTabs() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "unspentTalentPoints",
desc = 'Создай глобальную переменную unspentTalentPoints = GetUnspentTalentPoints() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][283] = {
type = "vartest",
title = "Тест: активный набор талантов",
helpModules = {281, 65},
tasks = {
{
var = "talentGroupCount",
desc = 'Создай глобальную переменную talentGroupCount = GetNumTalentGroups() or 1',
check = function(value)
return type(value) == "number" and value >= 1
end,
},
{
var = "activeTalentGroup",
desc = 'Создай глобальную переменную activeTalentGroup = GetActiveTalentGroup() or 1',
check = function(value)
return type(value) == "number" and value >= 1
end,
},
},
}

ns_llua['lua'][284] = {
type = "commenttest",
title = "Тест: функция GetTalentTabCountSafe",
helpModules = {281, 45, 65},
preloadVars = {
{var = "GetTalentTabCountSafe", desc = "GetTalentTabCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 257-3: функция GetTalentTabCountSafe</h>
<t>Создай глобальную функцию <k>GetTalentTabCountSafe()</k>.</t>
<t>Функция должна вернуть количество вкладок талантов через:</t>
<code>
GetNumTalentTabs()
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество вкладок.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetTalentTabCountSafe()
]=],
requireKeywords = {
"GetTalentTabCountSafe",
"function",
"GetNumTalentTabs",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetTalentTabCountSafe) ~= "function" then
_G.checkError = "GetTalentTabCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetTalentTabCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetTalentTabCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество вкладок талантов не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][285] = {
type = "commenttest",
title = "Тест: функция GetActiveTalentGroupSafe",
helpModules = {281, 45, 65},
preloadVars = {
{var = "GetActiveTalentGroupSafe", desc = "GetActiveTalentGroupSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 257-4: функция GetActiveTalentGroupSafe</h>
<t>Создай глобальную функцию <k>GetActiveTalentGroupSafe()</k>.</t>
<t>Функция должна вернуть номер активного набора талантов через:</t>
<code>
GetActiveTalentGroup()
</code>
<t>Если результат не является числом или меньше единицы, функция должна вернуть <n>1</n>.</t>
<t>Иначе функция должна вернуть номер активного набора.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetActiveTalentGroupSafe()
]=],
requireKeywords = {
"GetActiveTalentGroupSafe",
"function",
"GetActiveTalentGroup",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetActiveTalentGroupSafe) ~= "function" then
_G.checkError = "GetActiveTalentGroupSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetActiveTalentGroupSafe)
if not ok then
_G.checkError = "Ошибка вызова GetActiveTalentGroupSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 1 then
_G.checkError = "Номер активного набора талантов должен быть не меньше 1"
return false
end
return true
end,
}

ns_llua['lua'][286] = {
type = "commenttest",
title = "Тест: функция CountTalentsInTab",
helpModules = {281, 45, 31, 65},
preloadVars = {
{var = "CountTalentsInTab", desc = "CountTalentsInTab очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 257-5: функция CountTalentsInTab</h>
<t>Создай глобальную функцию <k>CountTalentsInTab(tab)</k>.</t>
<t>Если <k>tab</k> не является числом, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество талантов на вкладке через:</t>
<code>
GetNumTalents(tab)
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество талантов.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountTalentsInTab(tab)
]=],
requireKeywords = {
"CountTalentsInTab",
"function",
"GetNumTalents",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountTalentsInTab) ~= "function" then
_G.checkError = "CountTalentsInTab не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.CountTalentsInTab, 1)
if not ok1 then
_G.checkError = "Ошибка вызова CountTalentsInTab(1): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 then
_G.checkError = "Для tab = 1 функция должна вернуть число больше или равное нулю"
return false
end
local ok2, result2 = pcall(_G.CountTalentsInTab, -1)
if not ok2 or result2 ~= 0 then
_G.checkError = "Для tab = -1 функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.CountTalentsInTab, "bad")
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нечислового tab функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][287] = {
type = "info",
title = "Репутация фракций",
helpModules = {65, 45, 31},
content = [=[
<h>Репутация фракций</h>
<t>В WoW у игрока есть репутация с различными фракциями. Чем выше репутация, тем больше наград доступно.</t>
<w>Важно:</w> в списке репутации есть не только фракции, но и заголовки-категории. Их нужно отличать.
<h>GetNumFactions</h>
<code>
/run print(GetNumFactions())
</code>
<t>Возвращает общее количество записей в списке репутации. Это и фракции, и заголовки.</t>
<h>GetFactionInfo</h>
<code>
/run local name, desc, standingID, barMin, barMax, barValue = GetFactionInfo(1); print(name, standingID, barValue)
</code>
<t>Основные возвращаемые значения:</t>
<c>name</c> — название фракции или заголовка.
<c>description</c> — описание.
<c>standingID</c> — числовой уровень репутации.
<c>barMin</c> — минимальное значение полосы.
<c>barMax</c> — максимальное значение полосы.
<c>barValue</c> — текущее значение полосы.
<h>Уровни репутации (standingID)</h>
<c>1</c> — Ненависть (Hated).
<c>2</c> — Враждебность (Hostile).
<c>3</c> — Недружелюбие (Unfriendly).
<c>4</c> — Нейтралитет (Neutral).
<c>5</c> — Дружелюбие (Friendly).
<c>6</c> — Уважение (Honored).
<c>7</c> — Почтение (Revered).
<c>8</c> — Превознесение (Exalted).
<h>Заголовки и фракции</h>
<t>GetFactionInfo возвращает поле <k>isHeader</k>. Если оно истинно, это заголовок-категория, а не фракция.</t>
<code>
/run local name, _, _, _, _, _, _, _, isHeader = GetFactionInfo(1); print(name, isHeader)
</code>
<h>Отслеживаемая фракция</h>
<code>
/run local name, standingID, barMin, barMax, barValue = GetWatchedFactionInfo(); print(name or "Ничего не отслеживается")
</code>
<h>Перебор фракций</h>
<code>
/run local count = GetNumFactions() or 0; for i = 1, count do local name, _, standingID, _, _, _, _, _, isHeader = GetFactionInfo(i); if name and not isHeader then print(name, standingID) end end
</code>
<h>Безопасный шаблон</h>
<code>
/run local name = GetWatchedFactionInfo() or "Нет фракции"; print("Отслеживается: " .. name)
</code>
]=],
}

ns_llua['lua'][288] = {
type = "vartest",
title = "Тест: количество записей репутации",
helpModules = {287, 65},
tasks = {
{
var = "factionCount",
desc = 'Создай глобальную переменную factionCount = GetNumFactions() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "firstFactionName",
desc = 'Создай глобальную переменную firstFactionName = GetFactionInfo(1) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "firstFactionStanding",
desc = 'Создай глобальную переменную firstFactionStanding = select(3, GetFactionInfo(1)) or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 8
end,
},
},
}

ns_llua['lua'][289] = {
type = "vartest",
title = "Тест: отслеживаемая фракция",
helpModules = {287, 65},
tasks = {
{
var = "watchedFactionName",
desc = 'Создай глобальную переменную watchedFactionName = GetWatchedFactionInfo() or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "watchedFactionStanding",
desc = 'Создай глобальную переменную watchedFactionStanding = select(2, GetWatchedFactionInfo()) or 0',
check = function(value)
return type(value) == "number" and value >= 0 and value <= 8
end,
},
{
var = "watchedFactionBarValue",
desc = 'Создай глобальную переменную watchedFactionBarValue = select(5, GetWatchedFactionInfo()) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][290] = {
type = "commenttest",
title = "Тест: функция GetFactionCountSafe",
helpModules = {287, 45, 65},
preloadVars = {
{var = "GetFactionCountSafe", desc = "GetFactionCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 263-3: функция GetFactionCountSafe</h>
<t>Создай глобальную функцию <k>GetFactionCountSafe()</k>.</t>
<t>Функция должна вернуть количество записей в списке репутации через:</t>
<code>
GetNumFactions()
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество записей.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetFactionCountSafe()
]=],
requireKeywords = {
"GetFactionCountSafe",
"function",
"GetNumFactions",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetFactionCountSafe) ~= "function" then
_G.checkError = "GetFactionCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetFactionCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetFactionCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество записей не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][291] = {
type = "commenttest",
title = "Тест: функция GetFactionNameSafe",
helpModules = {287, 45, 65},
preloadVars = {
{var = "GetFactionNameSafe", desc = "GetFactionNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 263-4: функция GetFactionNameSafe</h>
<t>Создай глобальную функцию <k>GetFactionNameSafe(index)</k>.</t>
<t>Если <k>index</k> не является числом или меньше либо равно нуля, функция должна вернуть строку:</t>
<s>"нет"</s>
<t>Иначе функция должна получить имя записи репутации через:</t>
<code>
GetFactionInfo(index)
</code>
<t>Если имя не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"нет"</s>
<t>Иначе функция должна вернуть имя записи.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetFactionNameSafe(index)
]=],
requireKeywords = {
"GetFactionNameSafe",
"function",
"GetFactionInfo",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetFactionNameSafe) ~= "function" then
_G.checkError = "GetFactionNameSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetFactionNameSafe, 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetFactionNameSafe(1): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для index = 1 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetFactionNameSafe, 0)
if not ok2 or result2 ~= "нет" then
_G.checkError = "Для index = 0 функция должна вернуть 'нет'"
return false
end
local ok3, result3 = pcall(_G.GetFactionNameSafe, "bad")
if not ok3 or result3 ~= "нет" then
_G.checkError = "Для нечислового index функция должна вернуть 'нет'"
return false
end
local ok4, result4 = pcall(_G.GetFactionNameSafe, 999999)
if not ok4 then
_G.checkError = "Ошибка вызова GetFactionNameSafe(999999): " .. tostring(result4)
return false
end
if result4 ~= "нет" then
_G.checkError = "Для несуществующего index функция должна вернуть 'нет'"
return false
end
return true
end,
}

ns_llua['lua'][292] = {
type = "commenttest",
title = "Тест: функция GetWatchedFactionNameSafe",
helpModules = {287, 45, 65},
preloadVars = {
{var = "GetWatchedFactionNameSafe", desc = "GetWatchedFactionNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 263-5: функция GetWatchedFactionNameSafe</h>
<t>Создай глобальную функцию <k>GetWatchedFactionNameSafe()</k>.</t>
<t>Функция должна вернуть имя отслеживаемой фракции через:</t>
<code>
GetWatchedFactionInfo()
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна вернуть строку:</t>
<s>"нет"</s>
<t>Иначе функция должна вернуть имя отслеживаемой фракции.</t>
<t>Используй:</t>
<c>GetWatchedFactionInfo</c>
<c>type</c>
<c>return</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetWatchedFactionNameSafe()
]=],
requireKeywords = {
"GetWatchedFactionNameSafe",
"function",
"GetWatchedFactionInfo",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetWatchedFactionNameSafe) ~= "function" then
_G.checkError = "GetWatchedFactionNameSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetWatchedFactionNameSafe)
if not ok then
_G.checkError = "Ошибка вызова GetWatchedFactionNameSafe: " .. tostring(result)
return false
end
if type(result) ~= "string" or result == "" then
_G.checkError = "Функция должна вернуть непустую строку"
return false
end
return true
end,
}

ns_llua['lua'][293] = {
type = "info",
title = "Квесты: журнал и статусы",
helpModules = {65, 45, 31},
content = [=[
<h>Квесты: журнал и статусы</h>
<t>Журнал квестов содержит все активные квесты персонажа. Доступ к нему осуществляется через функции API.</t>
<w>Важно:</w> в WoW 3.3.5 нет прямой функции поиска квеста по ID. Для поиска нужно перебирать журнал вручную.
<h>GetNumQuestLogEntries</h>
<code>
/run print(GetNumQuestLogEntries())
</code>
<t>Возвращает количество записей в журнале квестов.</t>
<h>GetQuestLogTitle</h>
<code>
/run print(GetQuestLogTitle(1))
</code>
<t>Возвращает название квеста по индексу.</t>
<t>Если индекс неверный или квеста нет, функция может вернуть <k>nil</k>.</t>
<h>GetQuestLogLevel</h>
<code>
/run print(GetQuestLogLevel(1))
</code>
<t>Возвращает уровень квеста.</t>
<h>Перебор журнала квестов</h>
<code>
/run local count = GetNumQuestLogEntries() or 0; for i = 1, count do local title = GetQuestLogTitle(i); if title then print(i, title) end end
</code>
<h>GetQuestLogCompletionText</h>
<t>Возвращает текст завершения квеста, если квест готов к сдаче.</t>
<code>
/run print(GetQuestLogCompletionText() or "Квест не завершён")
</code>
<w>Примечание:</w> эта функция работает для текущего выбранного квеста. Для работы с конкретным квестом нужно сначала выбрать его через <k>SelectQuestLogEntry</k>.
<h>SelectQuestLogEntry</h>
<code>
/run SelectQuestLogEntry(1)
</code>
<t>Выбирает квест по индексу в журнале. После этого функции, работающие с текущим квестом, будут применяться к нему.</t>
<h>Подсчёт квестов по уровню</h>
<code>
/run local count = GetNumQuestLogEntries() or 0; local highLevel = 0; for i = 1, count do local level = GetQuestLogLevel(i); if level and level >= 70 then highLevel = highLevel + 1 end end; print("Квестов 70+: " .. highLevel)
</code>
<h>Безопасный шаблон</h>
<code>
/run local title = GetQuestLogTitle(1) or "Нет квеста"; print("Первый квест: " .. title)
</code>
]=],
}

ns_llua['lua'][294] = {
type = "vartest",
title = "Тест: количество квестов в журнале",
helpModules = {293, 65},
tasks = {
{
var = "questLogCount",
desc = 'Создай глобальную переменную questLogCount = GetNumQuestLogEntries() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][295] = {
type = "vartest",
title = "Тест: первый квест в журнале",
helpModules = {293, 65},
tasks = {
{
var = "firstQuestTitle",
desc = 'Создай глобальную переменную firstQuestTitle = GetQuestLogTitle(1) or "нет квеста"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "firstQuestLevel",
desc = 'Создай глобальную переменную firstQuestLevel = GetQuestLogLevel(1) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][296] = {
type = "commenttest",
title = "Тест: функция GetQuestLogCountSafe",
helpModules = {293, 45, 65},
preloadVars = {
{var = "GetQuestLogCountSafe", desc = "GetQuestLogCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 269-3: функция GetQuestLogCountSafe</h>
<t>Создай глобальную функцию <k>GetQuestLogCountSafe()</k>.</t>
<t>Функция должна вернуть количество записей в журнале квестов через:</t>
<code>
GetNumQuestLogEntries()
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество записей.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetQuestLogCountSafe()
]=],
requireKeywords = {
"GetQuestLogCountSafe",
"function",
"GetNumQuestLogEntries",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetQuestLogCountSafe) ~= "function" then
_G.checkError = "GetQuestLogCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetQuestLogCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetQuestLogCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество квестов не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][297] = {
type = "commenttest",
title = "Тест: функция GetQuestTitleSafe",
helpModules = {293, 45, 65},
preloadVars = {
{var = "GetQuestTitleSafe", desc = "GetQuestTitleSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 269-4: функция GetQuestTitleSafe</h>
<t>Создай глобальную функцию <k>GetQuestTitleSafe(index)</k>.</t>
<t>Если <k>index</k> не является числом или меньше либо равно нуля, функция должна вернуть строку:</t>
<s>"нет квеста"</s>
<t>Иначе функция должна получить название квеста через:</t>
<code>
GetQuestLogTitle(index)
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"нет квеста"</s>
<t>Иначе функция должна вернуть название квеста.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetQuestTitleSafe(index)
]=],
requireKeywords = {
"GetQuestTitleSafe",
"function",
"GetQuestLogTitle",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetQuestTitleSafe) ~= "function" then
_G.checkError = "GetQuestTitleSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetQuestTitleSafe, 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetQuestTitleSafe(1): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для index = 1 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetQuestTitleSafe, 0)
if not ok2 or result2 ~= "нет квеста" then
_G.checkError = "Для index = 0 функция должна вернуть 'нет квеста'"
return false
end
local ok3, result3 = pcall(_G.GetQuestTitleSafe, "bad")
if not ok3 or result3 ~= "нет квеста" then
_G.checkError = "Для нечислового index функция должна вернуть 'нет квеста'"
return false
end
return true
end,
}

ns_llua['lua'][298] = {
type = "commenttest",
title = "Тест: функция FindQuestInLog",
helpModules = {293, 45, 31, 33, 65},
preloadVars = {
{var = "FindQuestInLog", desc = "FindQuestInLog очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 269-5: функция FindQuestInLog</h>
<t>Создай глобальную функцию <k>FindQuestInLog(text)</k>.</t>
<t>Если <k>text</k> не является строкой или является пустой строкой, функция должна вернуть <k>nil</k>.</t>
<t>Иначе функция должна перебрать все записи журнала квестов и найти первый квест, в названии которого есть подстрока <k>text</k>.</t>
<t>Алгоритм:</t>
<t>1. Получи количество записей через <k>GetNumQuestLogEntries()</k>.</t>
<t>2. Перебери индексы от 1 до количества.</t>
<t>3. Для каждого индекса получи название через <k>GetQuestLogTitle(index)</k>.</t>
<t>4. Если название содержит подстроку <k>text</k>, верни индекс этого квеста.</t>
<t>5. Если ничего не найдено, верни <k>nil</k>.</t>
<t>Используй:</t>
<c>GetNumQuestLogEntries</c>
<c>GetQuestLogTitle</c>
<c>string.find</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию FindQuestInLog(text)
]=],
requireKeywords = {
"FindQuestInLog",
"function",
"GetNumQuestLogEntries",
"GetQuestLogTitle",
"string.find",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.FindQuestInLog) ~= "function" then
_G.checkError = "FindQuestInLog не является глобальной функцией"
return false
end
-- Тест 1: пустая строка
local ok1, result1 = pcall(_G.FindQuestInLog, "")
if not ok1 or result1 ~= nil then
_G.checkError = "Для пустой строки функция должна вернуть nil"
return false
end
-- Тест 2: не строка
local ok2, result2 = pcall(_G.FindQuestInLog, 123)
if not ok2 or result2 ~= nil then
_G.checkError = "Для нестрокового аргумента функция должна вернуть nil"
return false
end
-- Тест 3: несуществующая подстрока
local ok3, result3 = pcall(_G.FindQuestInLog, "zzz_no_such_quest_zzz")
if not ok3 then
_G.checkError = "Ошибка вызова FindQuestInLog с несуществующей строкой: " .. tostring(result3)
return false
end
if result3 ~= nil then
_G.checkError = "Для несуществующей подстроки функция должна вернуть nil"
return false
end
return true
end,
}

ns_llua['lua'][299] = {
type = "info",
title = "Парсинг ссылок предметов",
helpModules = {179, 33, 65},
content = [=[
<h>Парсинг ссылок предметов</h>
<t>В WoW предметы часто представлены в виде строк-ссылок. Такие ссылки используются в чате, тултипах и интерфейсе.</t>
<h>Как выглядит ссылка на предмет</h>
<code>
/run local name, link = GetItemInfo(6948); print(link)
</code>
<t>Типичная ссылка выглядит так:</t>
<code>
|cffA335EE|Hitem:6948:0:0:0:0:0:0:0|h[Камень возвращения]|h|r
</code>
<t>Разберём структуру:</t>
<c>|cffA335EE</c> — цвет качества предмета в hex.
<c>|Hitem:6948:0:0:0:0:0:0:0|h</c> — гиперссылка с ID предмета и параметрами.
<c>[Камень возвращения]</c> — название предмета в квадратных скобках.
<c>|h|r</c> — закрытие гиперссылки и сброс цвета.
<h>Цвета качества</h>
<c>9d9d9d</c> — бедный (0).
<c>ffffff</c> — обычный (1).
<c>1eff00</c> — необычный (2).
<c>0070dd</c> — редкий (3).
<c>a335ee</c> — эпический (4).
<c>ff8000</c> — легендарный (5).
<h>Получение ссылки на предмет</h>
<t>Ссылку можно получить через GetItemInfo:</t>
<code>
/run local name, link = GetItemInfo(6948); print(link or "нет ссылки")
</code>
<t>Или через сумку:</t>
<code>
/run print(GetContainerItemLink(0, 1) or "пусто")
</code>
<h>Парсинг через string.match</h>
<t>Функция string.match позволяет извлекать части строки по паттерну.</t>
<h>Извлечение ID предмета</h>
<code>
/run local name, link = GetItemInfo(6948); if link then local id = link:match("|Hitem:(%d+)"); print("ID: " .. tostring(id)) end
</code>
<t>Паттерн <k>|Hitem:(%d+)</k> ищет подстроку после <s>|Hitem:</s> и захватывает цифры в скобки.</t>
<w>Важно:</w> в Lua паттернах круглые скобки <k>()</k> означают захват, а <k>%d</k> означает цифру. Знак <k>+</k> означает один или более символов.
<h>Извлечение названия</h>
<code>
/run local name, link = GetItemInfo(6948); if link then local itemName = link:match("%[(.+)%]"); print("Название: " .. tostring(itemName)) end
</code>
<t>Паттерн <k>%[(.+)%]</k> ищет текст между квадратными скобками.</t>
<h>Извлечение цвета</h>
<code>
/run local name, link = GetItemInfo(6948); if link then local color = link:match("|cff(%x%x%x%x%x%x)"); print("Цвет: " .. tostring(color)) end
</code>
<t>Паттерн <k>|cff(%x%x%x%x%x%x)</k> захватывает 6 шестнадцатеричных символов после <s>|cff</s>.</t>
<h>Ссылки на заклинания</h>
<t>Ссылки на заклинания имеют другой формат:</t>
<code>
|cff71d5ff|Hspell:6603|h[Название заклинания]|h|r
</code>
<t>Здесь вместо <s>item</s> используется <s>spell</s>.</t>
<h>Безопасный шаблон</h>
<code>
/run local name, link = GetItemInfo(6948); if link then local id = link:match("|Hitem:(%d+)"); print("ID: " .. (id or "нет")) else print("Ссылки нет") end
</code>
<w>Примечание:</w> если предмет ещё не загружен в кэш, GetItemInfo может вернуть nil для ссылки. Поэтому всегда проверяй результат.
]=],
}

ns_llua['lua'][300] = {
type = "vartest",
title = "Тест: ссылка на камень возвращения",
helpModules = {299, 179, 65},
tasks = {
{
var = "hearthstoneLink",
desc = 'Создай глобальную переменную hearthstoneLink = select(2, GetItemInfo(6948)) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "hearthstoneLinkIsString",
desc = 'Создай глобальную переменную hearthstoneLinkIsString = type(select(2, GetItemInfo(6948)) or "нет") == "string"',
check = function(value)
return type(value) == "boolean" and value == true
end,
},
},
}

ns_llua['lua'][301] = {
type = "vartest",
title = "Тест: парсинг ссылки",
helpModules = {299, 33, 65},
tasks = {
{
var = "hearthstoneItemID",
desc = 'Создай глобальную переменную hearthstoneItemID: извлеки ID предмета из ссылки камня возвращения через string.match и паттерн "|Hitem:(%d+)". Если ссылки нет, используй 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "hearthstoneColor",
desc = 'Создай глобальную переменную hearthstoneColor: извлеки цвет качества из ссылки камня возвращения через string.match и паттерн "|cff(%x%x%x%x%x%x)". Если ссылки нет, используй "ffffff"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "hearthstoneBracketName",
desc = 'Создай глобальную переменную hearthstoneBracketName: извлеки название из квадратных скобок ссылки камня возвращения через string.match и паттерн "%[(.+)%]". Если ссылки нет, используй "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][302] = {
type = "commenttest",
title = "Тест: функция ExtractItemIDFromLink",
helpModules = {299, 33, 45, 65},
preloadVars = {
{var = "ExtractItemIDFromLink", desc = "ExtractItemIDFromLink очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 275-3: функция ExtractItemIDFromLink</h>
<t>Создай глобальную функцию <k>ExtractItemIDFromLink(link)</k>.</t>
<t>Если <k>link</k> не является строкой или является пустой строкой, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна извлечь ID предмета из ссылки через:</t>
<code>
link:match("|Hitem:(%d+)")
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть ID предмета как число.</t>
<t>Используй <k>tonumber</k> для преобразования строки в число.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию ExtractItemIDFromLink(link)
]=],
requireKeywords = {
"ExtractItemIDFromLink",
"function",
"string.match",
"tonumber",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.ExtractItemIDFromLink) ~= "function" then
_G.checkError = "ExtractItemIDFromLink не является глобальной функцией"
return false
end
-- Тест 1: реальная ссылка камня возвращения
local _, realLink = GetItemInfo(6948)
if realLink then
local ok1, result1 = pcall(_G.ExtractItemIDFromLink, realLink)
if not ok1 then
_G.checkError = "Ошибка вызова ExtractItemIDFromLink с реальной ссылкой: " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 ~= 6948 then
_G.checkError = "Для ссылки камня возвращения функция должна вернуть 6948"
return false
end
end
-- Тест 2: пустая строка
local ok2, result2 = pcall(_G.ExtractItemIDFromLink, "")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для пустой строки функция должна вернуть 0"
return false
end
-- Тест 3: не строка
local ok3, result3 = pcall(_G.ExtractItemIDFromLink, 123)
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нестрокового аргумента функция должна вернуть 0"
return false
end
-- Тест 4: строка без ссылки предмета
local ok4, result4 = pcall(_G.ExtractItemIDFromLink, "просто текст")
if not ok4 or result4 ~= 0 then
_G.checkError = "Для строки без ссылки предмета функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][303] = {
type = "commenttest",
title = "Тест: функция ExtractItemNameFromLink",
helpModules = {299, 33, 45, 65},
preloadVars = {
{var = "ExtractItemNameFromLink", desc = "ExtractItemNameFromLink очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 275-4: функция ExtractItemNameFromLink</h>
<t>Создай глобальную функцию <k>ExtractItemNameFromLink(link)</k>.</t>
<t>Если <k>link</k> не является строкой или является пустой строкой, функция должна вернуть строку:</t>
<s>"нет"</s>
<t>Иначе функция должна извлечь название предмета из квадратных скобок через:</t>
<code>
link:match("%[(.+)%]")
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"нет"</s>
<t>Иначе функция должна вернуть название предмета.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию ExtractItemNameFromLink(link)
]=],
requireKeywords = {
"ExtractItemNameFromLink",
"function",
"string.match",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.ExtractItemNameFromLink) ~= "function" then
_G.checkError = "ExtractItemNameFromLink не является глобальной функцией"
return false
end
-- Тест 1: реальная ссылка камня возвращения
local realName, realLink = GetItemInfo(6948)
if realLink then
local ok1, result1 = pcall(_G.ExtractItemNameFromLink, realLink)
if not ok1 then
_G.checkError = "Ошибка вызова ExtractItemNameFromLink с реальной ссылкой: " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для ссылки камня возвращения функция должна вернуть строку"
return false
end
end
-- Тест 2: пустая строка
local ok2, result2 = pcall(_G.ExtractItemNameFromLink, "")
if not ok2 or result2 ~= "нет" then
_G.checkError = "Для пустой строки функция должна вернуть 'нет'"
return false
end
-- Тест 3: не строка
local ok3, result3 = pcall(_G.ExtractItemNameFromLink, 123)
if not ok3 or result3 ~= "нет" then
_G.checkError = "Для нестрокового аргумента функция должна вернуть 'нет'"
return false
end
-- Тест 4: строка без квадратных скобок
local ok4, result4 = pcall(_G.ExtractItemNameFromLink, "просто текст")
if not ok4 or result4 ~= "нет" then
_G.checkError = "Для строки без квадратных скобок функция должна вернуть 'нет'"
return false
end
return true
end,
}

ns_llua['lua'][304] = {
type = "commenttest",
title = "Тест: функция IsItemLink",
helpModules = {299, 33, 45, 65},
preloadVars = {
{var = "IsItemLink", desc = "IsItemLink очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 275-5: функция IsItemLink</h>
<t>Создай глобальную функцию <k>IsItemLink(link)</k>.</t>
<t>Если <k>link</k> не является строкой или является пустой строкой, функция должна вернуть <k>false</k>.</t>
<t>Иначе функция должна проверить, является ли строка ссылкой на предмет.</t>
<t>Строка считается ссылкой на предмет, если она содержит подстроку:</t>
<s>"|Hitem:"</s>
<t>Используй <k>string.find</k> с четвёртым аргументом <k>true</k> для поиска без паттернов.</t>
<t>Функция должна вернуть <k>true</k> если строка является ссылкой на предмет, иначе <k>false</k>.</t>
<t>Результат должен быть именно boolean. Используй приведение через <k>and true or false</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию IsItemLink(link)
]=],
requireKeywords = {
"IsItemLink",
"function",
"string.find",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.IsItemLink) ~= "function" then
_G.checkError = "IsItemLink не является глобальной функцией"
return false
end
-- Тест 1: реальная ссылка камня возвращения
local _, realLink = GetItemInfo(6948)
if realLink then
local ok1, result1 = pcall(_G.IsItemLink, realLink)
if not ok1 then
_G.checkError = "Ошибка вызова IsItemLink с реальной ссылкой: " .. tostring(result1)
return false
end
if result1 ~= true then
_G.checkError = "Для реальной ссылки предмета функция должна вернуть true"
return false
end
end
-- Тест 2: пустая строка
local ok2, result2 = pcall(_G.IsItemLink, "")
if not ok2 or result2 ~= false then
_G.checkError = "Для пустой строки функция должна вернуть false"
return false
end
-- Тест 3: не строка
local ok3, result3 = pcall(_G.IsItemLink, 123)
if not ok3 or result3 ~= false then
_G.checkError = "Для нестрокового аргумента функция должна вернуть false"
return false
end
-- Тест 4: обычный текст
local ok4, result4 = pcall(_G.IsItemLink, "просто текст")
if not ok4 or result4 ~= false then
_G.checkError = "Для обычного текста функция должна вернуть false"
return false
end
-- Тест 5: ссылка на заклинание (не предмет)
local ok5, result5 = pcall(_G.IsItemLink, "|cff71d5ff|Hspell:6603|h[Тест]|h|r")
if not ok5 or result5 ~= false then
_G.checkError = "Для ссылки на заклинание функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][305] = {
type = "info",
title = "Статы персонажа и UnitStat",
helpModules = {65, 45, 10},
content = [=[
<h>Статы персонажа и UnitStat</h>
<t>Функция <k>UnitStat</k> возвращает характеристики персонажа: силу, ловкость, выносливость, интеллект и дух.</t>
<h>Индексы статов</h>
<c>1</c> — Сила (Strength).
<c>2</c> — Ловкость (Agility).
<c>3</c> — Выносливость (Stamina).
<c>4</c> — Интеллект (Intellect).
<c>5</c> — Дух (Spirit).
<h>UnitStat</h>
<code>
/run local base, effective, modifier = UnitStat("player", 1); print(base, effective, modifier)
</code>
<t>Функция возвращает три значения:</t>
<c>base</c> — базовое значение стата без баффов и дебаффов.
<c>effective</c> — эффективное значение с учётом всех модификаторов.
<c>modifier</c> — разница между эффективным и базовым значениями.
<h>Безопасный шаблон</h>
<code>
/run local base, effective = UnitStat("player", 1); print(base or 0, effective or 0)
</code>
<h>Атака и броня</h>
<code>
/run print(UnitAttackPower("player"))
/run print(UnitArmor("player"))
/run print(UnitDamage("player"))
/run print(UnitAttackSpeed("player"))
</code>
<t>Основные функции:</t>
<c>UnitAttackPower</c> — сила атаки.
<c>UnitRangedAttackPower</c> — сила дальней атаки.
<c>UnitDamage</c> — минимальный и максимальный урон.
<c>UnitAttackSpeed</c> — скорость атаки.
<c>UnitArmor</c> — броня.
<h>Сопротивления</h>
<code>
/run print(UnitResistance("player", 0))
</code>
<t>Индексы сопротивлений:</t>
<c>0</c> — физическое.
<c>1</c> — святое.
<c>2</c> — огонь.
<c>3</c> — природа.
<c>4</c> — лёд.
<c>5</c> — тьма.
<c>6</c> — тайная магия.
<h>Перебор всех статов</h>
<code>
/run for i = 1, 5 do local base, effective = UnitStat("player", i); print("Stat " .. i .. ": " .. (effective or 0)) end
</code>
<h>Таблица статов</h>
<code>
/run local stats = {}; for i = 1, 5 do local _, effective = UnitStat("player", i); stats[i] = effective or 0 end; print("Сила: " .. stats[1], "Ловкость: " .. stats[2])
</code>
<w>Важно:</w> значения статов зависят от баффов, экипировки и талантов. Эффективное значение может меняться в реальном времени.
]=],
}

ns_llua['lua'][306] = {
type = "vartest",
title = "Тест: базовые статы",
helpModules = {305, 65},
tasks = {
{
var = "playerStrength",
desc = 'Создай глобальную переменную playerStrength = select(2, UnitStat("player", 1)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerAgility",
desc = 'Создай глобальную переменную playerAgility = select(2, UnitStat("player", 2)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerStamina",
desc = 'Создай глобальную переменную playerStamina = select(2, UnitStat("player", 3)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][307] = {
type = "vartest",
title = "Тест: интеллект, дух, атака и броня",
helpModules = {305, 65},
tasks = {
{
var = "playerIntellect",
desc = 'Создай глобальную переменную playerIntellect = select(2, UnitStat("player", 4)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerSpirit",
desc = 'Создай глобальную переменную playerSpirit = select(2, UnitStat("player", 5)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerAttackPower",
desc = 'Создай глобальную переменную playerAttackPower = UnitAttackPower("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerArmor",
desc = 'Создай глобальную переменную playerArmor = UnitArmor("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][308] = {
type = "commenttest",
title = "Тест: функция GetStatSafe",
helpModules = {305, 45, 65},
preloadVars = {
{var = "GetStatSafe", desc = "GetStatSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 281-3: функция GetStatSafe</h>
<t>Создай глобальную функцию <k>GetStatSafe(unit, statIndex)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть <n>0</n>.</t>
<t>Если <k>statIndex</k> не является числом или меньше 1 или больше 5, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить эффективное значение стата через:</t>
<code>
select(2, UnitStat(unit, statIndex))
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть эффективное значение стата.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetStatSafe(unit, statIndex)
]=],
requireKeywords = {
"GetStatSafe",
"function",
"UnitStat",
"select",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetStatSafe) ~= "function" then
_G.checkError = "GetStatSafe не является глобальной функцией"
return false
end
-- Тест 1: корректный вызов для всех статов
for i = 1, 5 do
local ok, result = pcall(_G.GetStatSafe, "player", i)
if not ok then
_G.checkError = "Ошибка вызова GetStatSafe('player', " .. i .. "): " .. tostring(result)
return false
end
if type(result) ~= "number" or result < 0 then
_G.checkError = "Для statIndex = " .. i .. " функция должна вернуть число больше или равное нулю"
return false
end
end
-- Тест 2: некорректный unit
local ok2, result2 = pcall(_G.GetStatSafe, 123, 1)
if not ok2 or result2 ~= 0 then
_G.checkError = "Для нестрокового unit функция должна вернуть 0"
return false
end
-- Тест 3: некорректный statIndex
local ok3, result3 = pcall(_G.GetStatSafe, "player", 0)
if not ok3 or result3 ~= 0 then
_G.checkError = "Для statIndex = 0 функция должна вернуть 0"
return false
end
local ok4, result4 = pcall(_G.GetStatSafe, "player", 6)
if not ok4 or result4 ~= 0 then
_G.checkError = "Для statIndex = 6 функция должна вернуть 0"
return false
end
local ok5, result5 = pcall(_G.GetStatSafe, "player", "bad")
if not ok5 or result5 ~= 0 then
_G.checkError = "Для нечислового statIndex функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][309] = {
type = "commenttest",
title = "Тест: функция GetStatName",
helpModules = {305, 45, 17, 19},
preloadVars = {
{var = "GetStatName", desc = "GetStatName очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 281-4: функция GetStatName</h>
<t>Создай глобальную функцию <k>GetStatName(statIndex)</k>.</t>
<t>Функция должна вернуть название стата по индексу:</t>
<c>1</c> — <s>"Сила"</s>
<c>2</c> — <s>"Ловкость"</s>
<c>3</c> — <s>"Выносливость"</s>
<c>4</c> — <s>"Интеллект"</s>
<c>5</c> — <s>"Дух"</s>
<t>Если <k>statIndex</k> не является числом или меньше 1 или больше 5, функция должна вернуть:</t>
<s>"Неизвестно"</s>
<t>Используй:</t>
<c>type</c>
<c>if / elseif / else</c>
<c>return</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetStatName(statIndex)
]=],
requireKeywords = {
"GetStatName",
"function",
"type",
"if",
"elseif",
"else",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetStatName) ~= "function" then
_G.checkError = "GetStatName не является глобальной функцией"
return false
end
local tests = {
{input = 1, expected = "Сила"},
{input = 2, expected = "Ловкость"},
{input = 3, expected = "Выносливость"},
{input = 4, expected = "Интеллект"},
{input = 5, expected = "Дух"},
{input = 0, expected = "Неизвестно"},
{input = 6, expected = "Неизвестно"},
{input = "bad", expected = "Неизвестно"},
}
for i, test in ipairs(tests) do
local ok, result = pcall(_G.GetStatName, test.input)
if not ok or result ~= test.expected then
_G.checkError = "Тест " .. i .. " функции GetStatName не пройден"
return false
end
end
return true
end,
}

ns_llua['lua'][310] = {
type = "commenttest",
title = "Тест: функция GetStatReport",
helpModules = {305, 45, 31, 65, 7},
preloadVars = {
{var = "GetStatReport", desc = "GetStatReport очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 281-5: функция GetStatReport</h>
<t>Создай глобальную функцию <k>GetStatReport(unit)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть строку:</t>
<s>"Нет юнита"</s>
<t>Иначе функция должна собрать строку с эффективными значениями всех пяти статов.</t>
<t>Формат строки:</t>
<s>"Сила: X, Ловкость: X, Выносливость: X, Интеллект: X, Дух: X"</s>
<t>Где X — эффективное значение соответствующего стата.</t>
<t>Используй:</t>
<c>UnitStat(unit, index)</c>
<c>select(2, ...)</c>
<c>or 0</c>
<c>string.format</c>
<c>конкатенацию</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetStatReport(unit)
]=],
requireKeywords = {
"GetStatReport",
"function",
"UnitStat",
"select",
"string.format",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetStatReport) ~= "function" then
_G.checkError = "GetStatReport не является глобальной функцией"
return false
end
-- Тест 1: корректный вызов
local ok1, result1 = pcall(_G.GetStatReport, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetStatReport('player'): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для player функция должна вернуть строку"
return false
end
if not result1:find("Сила: ", 1, true) then
_G.checkError = "Строка должна содержать 'Сила: '"
return false
end
if not result1:find("Ловкость: ", 1, true) then
_G.checkError = "Строка должна содержать 'Ловкость: '"
return false
end
if not result1:find("Выносливость: ", 1, true) then
_G.checkError = "Строка должна содержать 'Выносливость: '"
return false
end
if not result1:find("Интеллект: ", 1, true) then
_G.checkError = "Строка должна содержать 'Интеллект: '"
return false
end
if not result1:find("Дух: ", 1, true) then
_G.checkError = "Строка должна содержать 'Дух: '"
return false
end
-- Тест 2: некорректный unit
local ok2, result2 = pcall(_G.GetStatReport, 123)
if not ok2 or result2 ~= "Нет юнита" then
_G.checkError = "Для нестрокового unit функция должна вернуть 'Нет юнита'"
return false
end
return true
end,
}

ns_llua['lua'][311] = {
type = "info",
title = "Атака, урон, броня и сопротивления",
helpModules = {305, 65, 45},
content = [=[
<h>Атака, урон, броня и сопротивления</h>
<t>WoW API предоставляет функции для получения боевых характеристик персонажа и других юнитов.</t>
<h>UnitAttackPower</h>
<code>
/run print(UnitAttackPower("player"))
</code>
<t>Возвращает силу атаки юнита. Чем выше значение, тем больше физический урон.</t>
<h>UnitRangedAttackPower</h>
<code>
/run print(UnitRangedAttackPower("player"))
</code>
<t>Возвращает силу дальней атаки. Актуально для классов с луками и арбалетами.</t>
<h>UnitDamage</h>
<code>
/run local minDmg, maxDmg = UnitDamage("player"); print(minDmg, maxDmg)
</code>
<t>Возвращает минимальный и максимальный урон юнита.</t>
<t>Если нужен средний урон, можно посчитать:</t>
<code>
/run local minDmg, maxDmg = UnitDamage("player"); if minDmg and maxDmg then print(string.format("Средний урон: %.1f", (minDmg + maxDmg) / 2)) end
</code>
<h>UnitAttackSpeed</h>
<code>
/run print(UnitAttackSpeed("player"))
</code>
<t>Возвращает скорость атаки в секундах. Меньшее значение — быстрее атака.</t>
<h>UnitArmor</h>
<code>
/run print(UnitArmor("player"))
</code>
<t>Возвращает значение брони юнита. Броня уменьшает получаемый физический урон.</t>
<h>UnitResistance</h>
<t>Возвращает сопротивление юнита к школе магии.</t>
<code>
/run print(UnitResistance("player", 0))
</code>
<t>Школы магии:</t>
<c>0</c> — физическое.
<c>1</c> — святое (Holy).
<c>2</c> — огонь (Fire).
<c>3</c> — природа (Nature).
<c>4</c> — лёд (Frost).
<c>5</c> — тьма (Shadow).
<c>6</c> — тайная магия (Arcane).
<h>Перебор всех сопротивлений</h>
<code>
/run for school = 0, 6 do print("Школа " .. school .. ": " .. (UnitResistance("player", school) or 0)) end
</code>
<h>Безопасный шаблон</h>
<code>
/run local ap = UnitAttackPower("player") or 0; local armor = UnitArmor("player") or 0; print(string.format("АП: %d, Броня: %d", ap, armor))
</code>
<w>Важно:</w> все эти функции могут вернуть <k>nil</k>, если юнит не существует или данные недоступны. Всегда используй <k>or 0</k> для безопасности.
<h>Пример боевого отчёта</h>
<code>
/run local ap = UnitAttackPower("player") or 0; local minD, maxD = UnitDamage("player"); local armor = UnitArmor("player") or 0; local speed = UnitAttackSpeed("player") or 0; print(string.format("АП: %d | Урон: %.0f-%.0f | Броня: %d | Скорость: %.1f", ap, minD or 0, maxD or 0, armor, speed))
</code>
]=],
}

ns_llua['lua'][312] = {
type = "vartest",
title = "Тест: сила атаки и броня",
helpModules = {311, 65},
tasks = {
{
var = "playerAttackPower",
desc = 'Создай глобальную переменную playerAttackPower = UnitAttackPower("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerRangedAttackPower",
desc = 'Создай глобальную переменную playerRangedAttackPower = UnitRangedAttackPower("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerArmor",
desc = 'Создай глобальную переменную playerArmor = UnitArmor("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][313] = {
type = "vartest",
title = "Тест: скорость атаки и урон",
helpModules = {311, 65},
tasks = {
{
var = "playerAttackSpeed",
desc = 'Создай глобальную переменную playerAttackSpeed = UnitAttackSpeed("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerMinDamage",
desc = 'Создай глобальную переменную playerMinDamage = UnitDamage("player") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "playerMaxDamage",
desc = 'Создай глобальную переменную playerMaxDamage = select(2, UnitDamage("player")) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][314] = {
type = "commenttest",
title = "Тест: функция GetAttackPowerSafe",
helpModules = {311, 45, 65},
preloadVars = {
{var = "GetAttackPowerSafe", desc = "GetAttackPowerSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 287-3: функция GetAttackPowerSafe</h>
<t>Создай глобальную функцию <k>GetAttackPowerSafe(unit)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить силу атаки через:</t>
<code>
UnitAttackPower(unit)
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть силу атаки.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetAttackPowerSafe(unit)
]=],
requireKeywords = {
"GetAttackPowerSafe",
"function",
"UnitAttackPower",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetAttackPowerSafe) ~= "function" then
_G.checkError = "GetAttackPowerSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetAttackPowerSafe, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetAttackPowerSafe('player'): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 then
_G.checkError = "Для player функция должна вернуть число больше или равное нулю"
return false
end
local ok2, result2 = pcall(_G.GetAttackPowerSafe, "ns_invalid_unit")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.GetAttackPowerSafe, 123)
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нестрокового unit функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][315] = {
type = "commenttest",
title = "Тест: функция GetDamageRange",
helpModules = {311, 45, 65},
preloadVars = {
{var = "GetDamageRange", desc = "GetDamageRange очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 287-4: функция GetDamageRange</h>
<t>Создай глобальную функцию <k>GetDamageRange(unit)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть два значения: <n>0</n> и <n>0</n>.</t>
<t>Иначе функция должна получить минимальный и максимальный урон через:</t>
<code>
UnitDamage(unit)
</code>
<t>Если минимальный урон не является числом или меньше нуля, верни <n>0</n> для минимального.</t>
<t>Если максимальный урон не является числом или меньше нуля, верни <n>0</n> для максимального.</t>
<t>Иначе функция должна вернуть два числа: минимальный урон и максимальный урон.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetDamageRange(unit)
]=],
requireKeywords = {
"GetDamageRange",
"function",
"UnitDamage",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetDamageRange) ~= "function" then
_G.checkError = "GetDamageRange не является глобальной функцией"
return false
end
local ok1, minD, maxD = pcall(_G.GetDamageRange, "player")
if not ok1 then
_G.checkError = "Ошибка вызова GetDamageRange('player'): " .. tostring(minD)
return false
end
if type(minD) ~= "number" or type(maxD) ~= "number" then
_G.checkError = "Для player функция должна вернуть два числа"
return false
end
if minD < 0 or maxD < 0 then
_G.checkError = "Значения урона не должны быть отрицательными"
return false
end
local ok2, invalidMin, invalidMax = pcall(_G.GetDamageRange, "ns_invalid_unit")
if not ok2 then
_G.checkError = "Ошибка вызова GetDamageRange('ns_invalid_unit'): " .. tostring(invalidMin)
return false
end
if invalidMin ~= 0 or invalidMax ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0 и 0"
return false
end
local ok3, badMin, badMax = pcall(_G.GetDamageRange, 123)
if not ok3 or badMin ~= 0 or badMax ~= 0 then
_G.checkError = "Для нестрокового unit функция должна вернуть 0 и 0"
return false
end
return true
end,
}

ns_llua['lua'][316] = {
type = "commenttest",
title = "Тест: функция GetResistanceSafe",
helpModules = {311, 45, 65},
preloadVars = {
{var = "GetResistanceSafe", desc = "GetResistanceSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 287-5: функция GetResistanceSafe</h>
<t>Создай глобальную функцию <k>GetResistanceSafe(unit, school)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть <n>0</n>.</t>
<t>Если <k>school</k> не является числом или меньше нуля или больше 6, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна получить сопротивление через:</t>
<code>
UnitResistance(unit, school)
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть значение сопротивления.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetResistanceSafe(unit, school)
]=],
requireKeywords = {
"GetResistanceSafe",
"function",
"UnitResistance",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetResistanceSafe) ~= "function" then
_G.checkError = "GetResistanceSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetResistanceSafe, "player", 0)
if not ok1 then
_G.checkError = "Ошибка вызова GetResistanceSafe('player', 0): " .. tostring(result1)
return false
end
if type(result1) ~= "number" or result1 < 0 then
_G.checkError = "Для player и школы 0 функция должна вернуть число больше или равное нулю"
return false
end
local ok2, result2 = pcall(_G.GetResistanceSafe, "ns_invalid_unit", 0)
if not ok2 or result2 ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.GetResistanceSafe, "player", -1)
if not ok3 or result3 ~= 0 then
_G.checkError = "Для школы -1 функция должна вернуть 0"
return false
end
local ok4, result4 = pcall(_G.GetResistanceSafe, "player", 7)
if not ok4 or result4 ~= 0 then
_G.checkError = "Для школы 7 функция должна вернуть 0"
return false
end
local ok5, result5 = pcall(_G.GetResistanceSafe, 123, 0)
if not ok5 or result5 ~= 0 then
_G.checkError = "Для нестрокового unit функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][317] = {
type = "info",
title = "Профессии и торговля",
helpModules = {65, 45, 31},
content = [=[
<h>Профессии и торговля</h>
<t>WoW API позволяет получать информацию о профессиях игрока и о товарах торговцев.</t>
<w>Важно:</w> данные о навыках профессии доступны только когда окно профессии открыто. Данные о торговце доступны только когда окно торговца открыто. Если окно не открыто, функции могут вернуть <k>nil</k>.
<h>GetNumTradeSkills</h>
<code>
/run print(GetNumTradeSkills())
</code>
<t>Возвращает количество рецептов в текущей профессии. Если окно профессии не открыто, может вернуть <k>nil</k>.</t>
<h>GetTradeSkillLine</h>
<code>
/run local name, rank, maxRank = GetTradeSkillLine(); print(name or "нет", rank or 0, maxRank or 0)
</code>
<t>Возвращает три значения:</t>
<c>name</c> — название профессии.
<c>rank</c> — текущий уровень навыка.
<c>maxRank</c> — максимальный уровень навыка.
<h>GetTradeSkillInfo</h>
<code>
/run local name, skillType, available = GetTradeSkillInfo(1); print(name or "нет", skillType or "нет")
</code>
<t>Возвращает информацию о рецепте:</t>
<c>name</c> — название рецепта.
<c>skillType</c> — тип: <s>"header"</s> (заголовок категории) или <s>"spell"</s> (рецепт).
<c>available</c> — доступно ли создание.
<h>Перебор рецептов</h>
<code>
/run local count = GetNumTradeSkills() or 0; for i = 1, count do local name, skillType = GetTradeSkillInfo(i); if name and skillType == "spell" then print(name) end end
</code>
<t>Здесь мы пропускаем заголовки категорий и выводим только рецепты.</t>
<h>GetMerchantNumItems</h>
<code>
/run print(GetMerchantNumItems())
</code>
<t>Возвращает количество предметов у торговца. Если окно торговца не открыто, может вернуть <k>nil</k> или <n>0</n>.</t>
<h>GetMerchantItemInfo</h>
<code>
/run local name, texture, price, quantity = GetMerchantItemInfo(1); print(name or "нет", price or 0, quantity or 0)
</code>
<t>Возвращает информацию о предмете торговца:</t>
<c>name</c> — название предмета.
<c>texture</c> — иконка предмета.
<c>price</c> — цена в меди.
<c>quantity</c> — количество предметов в стопке.
<c>numAvailable</c> — сколько штук доступно.
<c>isUsable</c> — можно ли использовать.
<h>Перебор товаров торговца</h>
<code>
/run local count = GetMerchantNumItems() or 0; for i = 1, count do local name, _, price = GetMerchantItemInfo(i); if name then print(i, name, price or 0) end end
</code>
<h>Цена в золоте</h>
<t>Цена возвращается в меди. Чтобы перевести в золото, серебро и медь:</t>
<code>
/run local _, _, price = GetMerchantItemInfo(1); price = price or 0; local gold = math.floor(price / 10000); local silver = math.floor((price % 10000) / 100); local copper = price % 100; print(string.format("%dз %dс %dм", gold, silver, copper))
</code>
<h>Безопасный шаблон</h>
<code>
/run local count = GetNumTradeSkills() or 0; local name = GetTradeSkillLine() or "нет"; print(string.format("Профессия: %s, рецептов: %d", name, count))
</code>
<w>Примечание:</w> если вы хотите получить данные о профессии или торговце в аддоне, вам нужно дождаться, пока игрок откроет соответствующее окно, и использовать события для отслеживания этого момента.
]=],
}

ns_llua['lua'][318] = {
type = "vartest",
title = "Тест: профессия игрока",
helpModules = {317, 65},
tasks = {
{
var = "tradeSkillCount",
desc = 'Создай глобальную переменную tradeSkillCount = GetNumTradeSkills() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "tradeSkillName",
desc = 'Создай глобальную переменную tradeSkillName = GetTradeSkillLine() or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "tradeSkillRank",
desc = 'Создай глобальную переменную tradeSkillRank = select(2, GetTradeSkillLine()) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][319] = {
type = "vartest",
title = "Тест: торговец и предметы",
helpModules = {317, 65},
tasks = {
{
var = "merchantItemCount",
desc = 'Создай глобальную переменную merchantItemCount = GetMerchantNumItems() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "merchantFirstItemName",
desc = 'Создай глобальную переменную merchantFirstItemName = GetMerchantItemInfo(1) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "merchantFirstItemPrice",
desc = 'Создай глобальную переменную merchantFirstItemPrice = select(3, GetMerchantItemInfo(1)) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][320] = {
type = "commenttest",
title = "Тест: функция GetTradeSkillCountSafe",
helpModules = {317, 45, 65},
preloadVars = {
{var = "GetTradeSkillCountSafe", desc = "GetTradeSkillCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 293-3: функция GetTradeSkillCountSafe</h>
<t>Создай глобальную функцию <k>GetTradeSkillCountSafe()</k>.</t>
<t>Функция должна вернуть количество рецептов в текущей профессии через:</t>
<code>
GetNumTradeSkills()
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество рецептов.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetTradeSkillCountSafe()
]=],
requireKeywords = {
"GetTradeSkillCountSafe",
"function",
"GetNumTradeSkills",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetTradeSkillCountSafe) ~= "function" then
_G.checkError = "GetTradeSkillCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetTradeSkillCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetTradeSkillCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество рецептов не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][321] = {
type = "commenttest",
title = "Тест: функция GetTradeSkillNameSafe",
helpModules = {317, 45, 65},
preloadVars = {
{var = "GetTradeSkillNameSafe", desc = "GetTradeSkillNameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 293-4: функция GetTradeSkillNameSafe</h>
<t>Создай глобальную функцию <k>GetTradeSkillNameSafe(index)</k>.</t>
<t>Если <k>index</k> не является числом или меньше либо равно нуля, функция должна вернуть строку:</t>
<s>"нет"</s>
<t>Иначе функция должна получить имя рецепта через:</t>
<code>
GetTradeSkillInfo(index)
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"нет"</s>
<t>Иначе функция должна вернуть имя рецепта.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetTradeSkillNameSafe(index)
]=],
requireKeywords = {
"GetTradeSkillNameSafe",
"function",
"GetTradeSkillInfo",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetTradeSkillNameSafe) ~= "function" then
_G.checkError = "GetTradeSkillNameSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetTradeSkillNameSafe, 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetTradeSkillNameSafe(1): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для index = 1 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetTradeSkillNameSafe, 0)
if not ok2 or result2 ~= "нет" then
_G.checkError = "Для index = 0 функция должна вернуть 'нет'"
return false
end
local ok3, result3 = pcall(_G.GetTradeSkillNameSafe, "bad")
if not ok3 or result3 ~= "нет" then
_G.checkError = "Для нечислового index функция должна вернуть 'нет'"
return false
end
local ok4, result4 = pcall(_G.GetTradeSkillNameSafe, 999999)
if not ok4 then
_G.checkError = "Ошибка вызова GetTradeSkillNameSafe(999999): " .. tostring(result4)
return false
end
if result4 ~= "нет" then
_G.checkError = "Для несуществующего index функция должна вернуть 'нет'"
return false
end
return true
end,
}

ns_llua['lua'][322] = {
type = "commenttest",
title = "Тест: функция GetMerchantItemCountSafe",
helpModules = {317, 45, 65},
preloadVars = {
{var = "GetMerchantItemCountSafe", desc = "GetMerchantItemCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 293-5: функция GetMerchantItemCountSafe</h>
<t>Создай глобальную функцию <k>GetMerchantItemCountSafe()</k>.</t>
<t>Функция должна вернуть количество предметов у торговца через:</t>
<code>
GetMerchantNumItems()
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество предметов.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetMerchantItemCountSafe()
]=],
requireKeywords = {
"GetMerchantItemCountSafe",
"function",
"GetMerchantNumItems",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetMerchantItemCountSafe) ~= "function" then
_G.checkError = "GetMerchantItemCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetMerchantItemCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetMerchantItemCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество предметов торговца не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][323] = {
type = "info",
title = "Питомцы и тотемы",
helpModules = {77, 83, 65},
content = [=[
<h>Питомцы и тотемы</h>
<t>В WoW у некоторых классов есть питомцы и тотемы. WoW API позволяет получать информацию о них.</t>
<h>Питомцы</h>
<t>Питомец доступен через UnitID <s>"pet"</s>.</t>
<code>
/run print(UnitExists("pet"))
/run print(UnitName("pet"))
/run print(UnitLevel("pet"))
</code>
<h>Проверка наличия питомца</h>
<t>Функция <k>UnitExists("pet")</k> проверяет, существует ли питомец в данный момент.</t>
<code>
/run if UnitExists("pet") then print("Питомец есть") else print("Питомца нет") end
</code>
<h>HasPetUI</h>
<t>Функция <k>HasPetUI()</k> проверяет, есть ли у игрока интерфейс питомца. Это зависит от класса.</t>
<code>
/run print(HasPetUI())
</code>
<t>Для охотника, чернокнижника и некоторых других классов вернёт истинное значение. Для воина, разбойника и т.д. вернёт <k>nil</k> или <k>false</k>.</t>
<h>Здоровье питомца</h>
<code>
/run local hp = UnitHealth("pet") or 0; local hpMax = UnitHealthMax("pet") or 0; print(hp, hpMax)
</code>
<h>Семейство питомца</h>
<code>
/run print(UnitCreatureFamily("pet") or "нет")
</code>
<t>Возвращает семейство существа, например "Волк", "Кошка", "Бес" и т.д.</t>
<h>Тотемы</h>
<t>Тотемы доступны через функцию <k>GetTotemInfo(slot)</k>.</t>
<t>Слоты тотемов:</t>
<c>1</c> — огонь.
<c>2</c> — земля.
<c>3</c> — вода.
<c>4</c> — воздух.
<h>GetTotemInfo</h>
<code>
/run local haveTotem, name = GetTotemInfo(1); print(haveTotem, name or "нет")
</code>
<t>Функция возвращает несколько значений:</t>
<c>haveTotem</c> — есть ли тотем в этом слоте.
<c>name</c> — название тотема.
<c>startTime</c> — время установки.
<c>duration</c> — длительность.
<c>icon</c> — иконка тотема.
<h>Оставшееся время тотема</h>
<code>
/run print(GetTotemTimeLeft(1) or 0)
</code>
<t>Функция <k>GetTotemTimeLeft(slot)</k> возвращает оставшееся время тотема в секундах.</t>
<h>Перебор всех тотемов</h>
<code>
/run for slot = 1, 4 do local have, name = GetTotemInfo(slot); if have then print("Слот " .. slot .. ": " .. (name or "нет")) end end
</code>
<h>Безопасный шаблон</h>
<code>
/run local have, name = GetTotemInfo(1); have = have or false; name = name or "нет"; print(have, name)
</code>
<w>Важно:</w> если класс игрока не может ставить тотемы, все значения <k>haveTotem</k> будут ложными.
]=],
}

ns_llua['lua'][324] = {
type = "vartest",
title = "Тест: питомец игрока",
helpModules = {323, 65},
tasks = {
{
var = "petExists",
desc = 'Создай глобальную переменную petExists = not not UnitExists("pet")',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "petName",
desc = 'Создай глобальную переменную petName = UnitName("pet") or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "petLevel",
desc = 'Создай глобальную переменную petLevel = UnitLevel("pet") or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][325] = {
type = "vartest",
title = "Тест: тотемы и HasPetUI",
helpModules = {323, 65},
tasks = {
{
var = "hasPetUI",
desc = 'Создай глобальную переменную hasPetUI = not not HasPetUI()',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "totem1Exists",
desc = 'Создай глобальную переменную totem1Exists = not not GetTotemInfo(1)',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "totem1Name",
desc = 'Создай глобальную переменную totem1Name = select(2, GetTotemInfo(1)) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][326] = {
type = "commenttest",
title = "Тест: функция HasPetSafe",
helpModules = {323, 45, 65},
preloadVars = {
{var = "HasPetSafe", desc = "HasPetSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 299-3: функция HasPetSafe</h>
<t>Создай глобальную функцию <k>HasPetSafe()</k>.</t>
<t>Функция должна вернуть <k>true</k>, если у игрока есть питомец.</t>
<t>Иначе функция должна вернуть <k>false</k>.</t>
<t>Используй:</t>
<c>UnitExists("pet")</c>
<t>Чтобы результат был именно boolean, используй конструкцию:</t>
<code>
return UnitExists("pet") and true or false
</code>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию HasPetSafe()
]=],
requireKeywords = {
"HasPetSafe",
"function",
"UnitExists",
"pet",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.HasPetSafe) ~= "function" then
_G.checkError = "HasPetSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.HasPetSafe)
if not ok then
_G.checkError = "Ошибка вызова HasPetSafe: " .. tostring(result)
return false
end
if type(result) ~= "boolean" then
_G.checkError = "Функция должна вернуть boolean"
return false
end
return true
end,
}

ns_llua['lua'][327] = {
type = "commenttest",
title = "Тест: функция GetPetHealthPercent",
helpModules = {323, 83, 65, 45},
preloadVars = {
{var = "GetPetHealthPercent", desc = "GetPetHealthPercent очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 299-4: функция GetPetHealthPercent</h>
<t>Создай глобальную функцию <k>GetPetHealthPercent()</k>.</t>
<t>Если питомца не существует, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть процент здоровья питомца от 0 до 100.</t>
<t>Используй:</t>
<c>UnitExists("pet")</c>
<c>UnitHealth("pet")</c>
<c>UnitHealthMax("pet")</c>
<c>or 0</c>
<c>math.floor</c>
<t>Если максимальное здоровье меньше или равно нуля, функция должна вернуть <n>0</n>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetPetHealthPercent()
]=],
requireKeywords = {
"GetPetHealthPercent",
"function",
"UnitExists",
"UnitHealth",
"UnitHealthMax",
"math.floor",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetPetHealthPercent) ~= "function" then
_G.checkError = "GetPetHealthPercent не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetPetHealthPercent)
if not ok then
_G.checkError = "Ошибка вызова GetPetHealthPercent: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 or result > 100 then
_G.checkError = "Процент здоровья питомца должен быть от 0 до 100"
return false
end
return true
end,
}

ns_llua['lua'][328] = {
type = "commenttest",
title = "Тест: функция GetTotemInfoSafe",
helpModules = {323, 45, 65},
preloadVars = {
{var = "GetTotemInfoSafe", desc = "GetTotemInfoSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 299-5: функция GetTotemInfoSafe</h>
<t>Создай глобальную функцию <k>GetTotemInfoSafe(slot)</k>.</t>
<t>Если <k>slot</k> не является числом или меньше 1 или больше 4, функция должна вернуть два значения: <k>false</k> и строку <s>"нет"</s>.</t>
<t>Иначе функция должна получить данные тотема через:</t>
<code>
GetTotemInfo(slot)
</code>
<t>Если тотема нет, функция должна вернуть два значения: <k>false</k> и строку <s>"нет"</s>.</t>
<t>Если тотем есть, функция должна вернуть два значения: <k>true</k> и имя тотема.</t>
<t>Если имя тотема не является строкой или является пустой строкой, используй строку:</t>
<s>"нет"</s>
<t>Используй:</t>
<c>GetTotemInfo</c>
<c>select</c>
<c>type</c>
<c>return</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetTotemInfoSafe(slot)
]=],
requireKeywords = {
"GetTotemInfoSafe",
"function",
"GetTotemInfo",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetTotemInfoSafe) ~= "function" then
_G.checkError = "GetTotemInfoSafe не является глобальной функцией"
return false
end
-- Тест 1: корректный слот
local ok1, exists1, name1 = pcall(_G.GetTotemInfoSafe, 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetTotemInfoSafe(1): " .. tostring(exists1)
return false
end
if type(exists1) ~= "boolean" then
_G.checkError = "Первое значение должно быть boolean"
return false
end
if type(name1) ~= "string" then
_G.checkError = "Второе значение должно быть строкой"
return false
end
-- Тест 2: некорректный слот
local ok2, exists2, name2 = pcall(_G.GetTotemInfoSafe, 0)
if not ok2 then
_G.checkError = "Ошибка вызова GetTotemInfoSafe(0): " .. tostring(exists2)
return false
end
if exists2 ~= false then
_G.checkError = "Для слота 0 первое значение должно быть false"
return false
end
if name2 ~= "нет" then
_G.checkError = "Для слота 0 второе значение должно быть 'нет'"
return false
end
-- Тест 3: некорректный слот
local ok3, exists3, name3 = pcall(_G.GetTotemInfoSafe, 5)
if not ok3 then
_G.checkError = "Ошибка вызова GetTotemInfoSafe(5): " .. tostring(exists3)
return false
end
if exists3 ~= false then
_G.checkError = "Для слота 5 первое значение должно быть false"
return false
end
if name3 ~= "нет" then
_G.checkError = "Для слота 5 второе значение должно быть 'нет'"
return false
end
-- Тест 4: нечисловой слот
local ok4, exists4, name4 = pcall(_G.GetTotemInfoSafe, "bad")
if not ok4 then
_G.checkError = "Ошибка вызова GetTotemInfoSafe('bad'): " .. tostring(exists4)
return false
end
if exists4 ~= false then
_G.checkError = "Для нечислового слота первое значение должно быть false"
return false
end
if name4 ~= "нет" then
_G.checkError = "Для нечислового слота второе значение должно быть 'нет'"
return false
end
return true
end,
}

ns_llua['lua'][329] = {
type = "info",
title = "Почта и банк",
helpModules = {65, 45, 31},
content = [=[
<h>Почта и банк</h>
<t>WoW API позволяет получать информацию о почте и банке персонажа.</t>
<w>Важно:</w> данные о почте и банке доступны только когда окно почты или банка открыто. Если окно не открыто, функции могут вернуть <k>nil</k>.
<h>CheckInbox</h>
<code>
/run CheckInbox()
</code>
<t>Эта функция обновляет данные почты. Её нужно вызвать перед получением информации о письмах.</t>
<h>GetInboxNumItems</h>
<code>
/run print(GetInboxNumItems())
</code>
<t>Возвращает количество писем в почтовом ящике.</t>
<h>GetInboxHeaderInfo</h>
<code>
/run local sender, subject = GetInboxHeaderInfo(1); print(sender or "нет", subject or "нет")
</code>
<t>Возвращает данные о письме:</t>
<c>sender</c> — имя отправителя.
<c>subject</c> — тема письма.
<c>money</c> — сумма денег в письме.
<c>COD</c> — сумма наложенного платежа.
<c>daysLeft</c> — сколько дней осталось до удаления письма.
<c>itemCount</c> — количество предметов в письме.
<c>wasRead</c> — прочитано ли письмо.
<c>wasReturned</c> — возвращено ли письмо.
<c>textCreated</c> — создан ли текст письма.
<c>canReply</c> — можно ли ответить.
<h>GetInboxText</h>
<code>
/run local text = GetInboxText(1); print(text or "нет текста")
</code>
<t>Возвращает текст письма.</t>
<h>Перебор писем</h>
<code>
/run local count = GetInboxNumItems() or 0; for i = 1, count do local sender, subject = GetInboxHeaderInfo(i); print(i, sender or "нет", subject or "нет") end
</code>
<h>GetNumBankSlots</h>
<code>
/run print(GetNumBankSlots())
</code>
<t>Возвращает количество слотов банка.</t>
<h>GetBankSlotCost</h>
<code>
/run print(GetBankSlotCost(1))
</code>
<t>Возвращает стоимость слота банка в меди.</t>
<h>Безопасный шаблон</h>
<code>
/run local count = GetInboxNumItems() or 0; print(string.format("Писем: %d", count))
</code>
<w>Примечание:</w> если вы хотите получить данные о почте или банке в аддоне, вам нужно дождаться, пока игрок откроет соответствующее окно, и использовать события для отслеживания этого момента.
]=],
}

ns_llua['lua'][330] = {
type = "vartest",
title = "Тест: почта игрока",
helpModules = {329, 65},
tasks = {
{
var = "inboxItemCount",
desc = 'Создай глобальную переменную inboxItemCount = GetInboxNumItems() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "firstMailSender",
desc = 'Создай глобальную переменную firstMailSender = GetInboxHeaderInfo(1) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "firstMailSubject",
desc = 'Создай глобальную переменную firstMailSubject = select(2, GetInboxHeaderInfo(1)) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][331] = {
type = "vartest",
title = "Тест: банк игрока",
helpModules = {329, 65},
tasks = {
{
var = "bankSlotCount",
desc = 'Создай глобальную переменную bankSlotCount = GetNumBankSlots() or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
{
var = "firstBankSlotCost",
desc = 'Создай глобальную переменную firstBankSlotCost = GetBankSlotCost(1) or 0',
check = function(value)
return type(value) == "number" and value >= 0
end,
},
},
}

ns_llua['lua'][332] = {
type = "commenttest",
title = "Тест: функция GetInboxItemCountSafe",
helpModules = {329, 45, 65},
preloadVars = {
{var = "GetInboxItemCountSafe", desc = "GetInboxItemCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 305-3: функция GetInboxItemCountSafe</h>
<t>Создай глобальную функцию <k>GetInboxItemCountSafe()</k>.</t>
<t>Функция должна вернуть количество писем в почтовом ящике через:</t>
<code>
GetInboxNumItems()
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество писем.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetInboxItemCountSafe()
]=],
requireKeywords = {
"GetInboxItemCountSafe",
"function",
"GetInboxNumItems",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetInboxItemCountSafe) ~= "function" then
_G.checkError = "GetInboxItemCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetInboxItemCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetInboxItemCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество писем не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][333] = {
type = "commenttest",
title = "Тест: функция GetMailSubjectSafe",
helpModules = {329, 45, 65},
preloadVars = {
{var = "GetMailSubjectSafe", desc = "GetMailSubjectSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 305-4: функция GetMailSubjectSafe</h>
<t>Создай глобальную функцию <k>GetMailSubjectSafe(index)</k>.</t>
<t>Если <k>index</k> не является числом или меньше либо равно нуля, функция должна вернуть строку:</t>
<s>"нет"</s>
<t>Иначе функция должна получить тему письма через:</t>
<code>
select(2, GetInboxHeaderInfo(index))
</code>
<t>Если результат не является строкой или является пустой строкой, функция должна вернуть:</t>
<s>"нет"</s>
<t>Иначе функция должна вернуть тему письма.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetMailSubjectSafe(index)
]=],
requireKeywords = {
"GetMailSubjectSafe",
"function",
"GetInboxHeaderInfo",
"select",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetMailSubjectSafe) ~= "function" then
_G.checkError = "GetMailSubjectSafe не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.GetMailSubjectSafe, 1)
if not ok1 then
_G.checkError = "Ошибка вызова GetMailSubjectSafe(1): " .. tostring(result1)
return false
end
if type(result1) ~= "string" or result1 == "" then
_G.checkError = "Для index = 1 функция должна вернуть строку"
return false
end
local ok2, result2 = pcall(_G.GetMailSubjectSafe, 0)
if not ok2 or result2 ~= "нет" then
_G.checkError = "Для index = 0 функция должна вернуть 'нет'"
return false
end
local ok3, result3 = pcall(_G.GetMailSubjectSafe, "bad")
if not ok3 or result3 ~= "нет" then
_G.checkError = "Для нечислового index функция должна вернуть 'нет'"
return false
end
return true
end,
}

ns_llua['lua'][334] = {
type = "commenttest",
title = "Тест: функция GetBankSlotCountSafe",
helpModules = {329, 45, 65},
preloadVars = {
{var = "GetBankSlotCountSafe", desc = "GetBankSlotCountSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 305-5: функция GetBankSlotCountSafe</h>
<t>Создай глобальную функцию <k>GetBankSlotCountSafe()</k>.</t>
<t>Функция должна вернуть количество слотов банка через:</t>
<code>
GetNumBankSlots()
</code>
<t>Если результат не является числом или меньше нуля, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна вернуть количество слотов банка.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetBankSlotCountSafe()
]=],
requireKeywords = {
"GetBankSlotCountSafe",
"function",
"GetNumBankSlots",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetBankSlotCountSafe) ~= "function" then
_G.checkError = "GetBankSlotCountSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.GetBankSlotCountSafe)
if not ok then
_G.checkError = "Ошибка вызова GetBankSlotCountSafe: " .. tostring(result)
return false
end
if type(result) ~= "number" then
_G.checkError = "Функция должна вернуть число"
return false
end
if result < 0 then
_G.checkError = "Количество слотов банка не может быть отрицательным"
return false
end
return true
end,
}

ns_llua['lua'][335] = {
type = "info",
title = "SavedVariables и сохранение данных",
helpModules = {44, 65, 45},
content = [=[
<h>SavedVariables и сохранение данных</h>
<t>В WoW 3.3.5 данные аддонов сохраняются между сессиями через механизм SavedVariables. Это позволяет аддону запоминать настройки, позиции, статистику и другие данные игрока.</t>
<h>Как это работает</h>
<t>В файле аддона с расширением <c>.toc</c> указываются имена глобальных переменных, которые нужно сохранять:</t>
<code>
## SavedVariables: MyAddonDB
## SavedVariablesPerCharacter: MyAddonCharDB
</code>
<t>Разница:</t>
<c>SavedVariables</c> — переменная общая для всех персонажей на аккаунте.
<c>SavedVariablesPerCharacter</c> — переменная уникальная для каждого персонажа.
<h>Когда данные сохраняются</h>
<t>WoW сохраняет данные при:</t>
<c>/reload</c> — перезагрузка интерфейса.
Выход из игры.
Смена персонажа.
<w>Важно:</w> если игрок убьёт процесс игры через диспетчер задач, данные могут не сохраниться.
<h>Глобальная переменная как хранилище</h>
<t>Обычно для сохранения используют одну глобальную таблицу:</t>
<code>
MyAddonDB = MyAddonDB or {}
</code>
<t>Конструкция <k>or {}</k> гарантирует, что при первом запуске (когда переменная ещё <k>nil</k>) будет создана пустая таблица.</t>
<h>Хранение данных в таблице</h>
<code>
MyAddonDB = MyAddonDB or {}
MyAddonDB.settings = MyAddonDB.settings or {}
MyAddonDB.settings.showMinimap = true
MyAddonDB.settings.fontSize = 12
MyAddonDB.lastLogin = time()
</code>
<h>Безопасная инициализация</h>
<t>При загрузке аддона нужно проверить, существуют ли данные, и создать значения по умолчанию:</t>
<code>
MyAddonDB = MyAddonDB or {}
MyAddonDB.settings = MyAddonDB.settings or {}
if MyAddonDB.settings.fontSize == nil then
    MyAddonDB.settings.fontSize = 12
end
</code>
<h>Чтение сохранённых данных</h>
<code>
MyAddonDB = MyAddonDB or {}
local fontSize = MyAddonDB.settings and MyAddonDB.settings.fontSize or 12
print("Размер шрифта: " .. fontSize)
</code>
<w>Важно:</w> если <k>MyAddonDB.settings</k> равно <k>nil</k>, то попытка прочитать <k>MyAddonDB.settings.fontSize</k> вызовет ошибку. Поэтому сначала проверяем наличие <k>settings</k>.
<h>Сохранение при выходе</h>
<t>Данные сохраняются автоматически при выходе. Но если нужно сохранить что-то в момент события, можно использовать:</t>
<code>
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGOUT")
f:SetScript("OnEvent", function()
    MyAddonDB = MyAddonDB or {}
    MyAddonDB.lastLogout = time()
end)
</code>
<h>Функция time()</h>
<code>
/run print(time())
</code>
<t>Возвращает текущее время в секундах с 1 января 1970 года (Unix timestamp).</t>
]=],
}

ns_llua['lua'][336] = {
type = "vartest",
title = "Тест: структура для сохранения",
helpModules = {335, 44},
tasks = {
{
var = "nsCourseDB",
desc = 'Создай глобальную переменную nsCourseDB = {} (пустая таблица, имитация хранилища)',
check = function(value)
return type(value) == "table"
end,
},
{
var = "nsCourseDB_settings",
desc = 'Создай глобальную переменную nsCourseDB_settings: присвой nsCourseDB.settings = {} и затем сохрани ссылку в nsCourseDB_settings',
check = function(value)
return type(value) == "table"
end,
},
},
}

ns_llua['lua'][337] = {
type = "vartest",
title = "Тест: безопасная инициализация",
helpModules = {335, 44, 65},
tasks = {
{
var = "nsSafeDB",
desc = 'Создай глобальную переменную nsSafeDB: используй конструкцию nsSafeDB = nsSafeDB or {} для безопасной инициализации',
check = function(value)
return type(value) == "table"
end,
},
{
var = "nsSafeDB_defaultValue",
desc = 'Создай глобальную переменную nsSafeDB_defaultValue: если nsSafeDB.value равно nil, присвой 42, иначе оставь как есть. Сохрани результат в nsSafeDB_defaultValue',
check = function(value)
return type(value) == "number" and value == 42
end,
},
},
}

ns_llua['lua'][338] = {
type = "commenttest",
title = "Тест: функция SaveKeyValue",
helpModules = {335, 44, 45},
preloadVars = {
{var = "SaveKeyValue", desc = "SaveKeyValue очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
{var = "nsTestDB", desc = "nsTestDB очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 311-3: функция SaveKeyValue</h>
<t>Создай глобальную функцию <k>SaveKeyValue(db, key, value)</k>.</t>
<t>Если <k>db</k> не является таблицей, функция должна вернуть <k>false</k>.</t>
<t>Если <k>key</k> не является строкой или является пустой строкой, функция должна вернуть <k>false</k>.</t>
<t>Иначе функция должна сохранить значение в таблицу: <k>db[key] = value</k> и вернуть <k>true</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию SaveKeyValue(db, key, value)
]=],
requireKeywords = {
"SaveKeyValue",
"function",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.SaveKeyValue) ~= "function" then
_G.checkError = "SaveKeyValue не является глобальной функцией"
return false
end
_G.nsTestDB = {}
local ok1, result1 = pcall(_G.SaveKeyValue, _G.nsTestDB, "testKey", 123)
if not ok1 then
_G.checkError = "Ошибка вызова SaveKeyValue: " .. tostring(result1)
return false
end
if result1 ~= true then
_G.checkError = "Для корректных данных функция должна вернуть true"
return false
end
if _G.nsTestDB.testKey ~= 123 then
_G.checkError = "Значение не было сохранено в таблицу"
return false
end
local ok2, result2 = pcall(_G.SaveKeyValue, nil, "key", 1)
if not ok2 or result2 ~= false then
_G.checkError = "Для nil-таблицы функция должна вернуть false"
return false
end
local ok3, result3 = pcall(_G.SaveKeyValue, _G.nsTestDB, "", 1)
if not ok3 or result3 ~= false then
_G.checkError = "Для пустого ключа функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][339] = {
type = "commenttest",
title = "Тест: функция LoadKeyValue",
helpModules = {335, 44, 45, 65},
preloadVars = {
{var = "LoadKeyValue", desc = "LoadKeyValue очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 311-4: функция LoadKeyValue</h>
<t>Создай глобальную функцию <k>LoadKeyValue(db, key, default)</k>.</t>
<t>Если <k>db</k> не является таблицей, функция должна вернуть <k>default</k>.</t>
<t>Если <k>key</k> не является строкой или является пустой строкой, функция должна вернуть <k>default</k>.</t>
<t>Если <k>db[key]</k> равно <k>nil</k>, функция должна вернуть <k>default</k>.</t>
<t>Иначе функция должна вернуть <k>db[key]</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию LoadKeyValue(db, key, default)
]=],
requireKeywords = {
"LoadKeyValue",
"function",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.LoadKeyValue) ~= "function" then
_G.checkError = "LoadKeyValue не является глобальной функцией"
return false
end
local testDB = { existingKey = "hello", numKey = 42 }
local ok1, result1 = pcall(_G.LoadKeyValue, testDB, "existingKey", "default")
if not ok1 then
_G.checkError = "Ошибка вызова LoadKeyValue: " .. tostring(result1)
return false
end
if result1 ~= "hello" then
_G.checkError = "Для существующего ключа функция должна вернуть значение из таблицы"
return false
end
local ok2, result2 = pcall(_G.LoadKeyValue, testDB, "missingKey", "default")
if not ok2 or result2 ~= "default" then
_G.checkError = "Для отсутствующего ключа функция должна вернуть default"
return false
end
local ok3, result3 = pcall(_G.LoadKeyValue, nil, "key", "default")
if not ok3 or result3 ~= "default" then
_G.checkError = "Для nil-таблицы функция должна вернуть default"
return false
end
local ok4, result4 = pcall(_G.LoadKeyValue, testDB, "", "default")
if not ok4 or result4 ~= "default" then
_G.checkError = "Для пустого ключа функция должна вернуть default"
return false
end
return true
end,
}

ns_llua['lua'][340] = {
type = "commenttest",
title = "Тест: функция InitSavedData",
helpModules = {335, 44, 45, 17},
preloadVars = {
{var = "InitSavedData", desc = "InitSavedData очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 311-5: функция InitSavedData</h>
<t>Создай глобальную функцию <k>InitSavedData(db)</k>.</t>
<t>Если <k>db</k> не является таблицей, функция должна вернуть <k>nil</k>.</t>
<t>Иначе функция должна проверить и создать поля по умолчанию:</t>
<t>- если <k>db.settings</k> равно <k>nil</k>, создай пустую таблицу: <k>db.settings = {}</k>;</t>
<t>- если <k>db.settings.fontSize</k> равно <k>nil</k>, присвой <n>12</n>;</t>
<t>- если <k>db.settings.showMinimap</k> равно <k>nil</k>, присвой <k>true</k>;</t>
<t>- если <k>db.stats</k> равно <k>nil</k>, создай пустую таблицу: <k>db.stats = {}</k>;</t>
<t>- если <k>db.stats.loginCount</k> равно <k>nil</k>, присвой <n>0</n>;</t>
<t>- верни таблицу <k>db</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию InitSavedData(db)
]=],
requireKeywords = {
"InitSavedData",
"function",
"if",
"then",
"nil",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.InitSavedData) ~= "function" then
_G.checkError = "InitSavedData не является глобальной функцией"
return false
end
-- Тест 1: пустая таблица
local testDB1 = {}
local ok1, result1 = pcall(_G.InitSavedData, testDB1)
if not ok1 then
_G.checkError = "Ошибка вызова InitSavedData с пустой таблицей: " .. tostring(result1)
return false
end
if type(result1) ~= "table" then
_G.checkError = "Для пустой таблицы функция должна вернуть таблицу"
return false
end
if type(result1.settings) ~= "table" then
_G.checkError = "Поле settings должно быть таблицей"
return false
end
if result1.settings.fontSize ~= 12 then
_G.checkError = "Поле settings.fontSize должно быть 12"
return false
end
if result1.settings.showMinimap ~= true then
_G.checkError = "Поле settings.showMinimap должно быть true"
return false
end
if type(result1.stats) ~= "table" then
_G.checkError = "Поле stats должно быть таблицей"
return false
end
if result1.stats.loginCount ~= 0 then
_G.checkError = "Поле stats.loginCount должно быть 0"
return false
end
-- Тест 2: таблица с уже существующими данными
local testDB2 = {
settings = { fontSize = 20 },
stats = { loginCount = 5 },
}
local ok2, result2 = pcall(_G.InitSavedData, testDB2)
if not ok2 then
_G.checkError = "Ошибка вызова InitSavedData с заполненной таблицей: " .. tostring(result2)
return false
end
if result2.settings.fontSize ~= 20 then
_G.checkError = "Существующее значение fontSize не должно быть перезаписано"
return false
end
if result2.stats.loginCount ~= 5 then
_G.checkError = "Существующее значение loginCount не должно быть перезаписано"
return false
end
if result2.settings.showMinimap ~= true then
_G.checkError = "Отсутствующее поле showMinimap должно быть создано со значением true"
return false
end
-- Тест 3: nil
local ok3, result3 = pcall(_G.InitSavedData, nil)
if not ok3 or result3 ~= nil then
_G.checkError = "Для nil функция должна вернуть nil"
return false
end
return true
end,
}

ns_llua['lua'][341] = {
type = "info",
title = "Аддон-коммуникация: SendAddonMessage",
helpModules = {239, 335},
content = [=[
<h>Аддон-коммуникация: SendAddonMessage</h>
<t>Аддоны могут обмениваться скрытыми сообщениями между игроками. Это позволяет синхронизировать данные, передавать настройки, координировать действия в группе или рейде.</t>
<h>Как это работает</h>
<t>Один аддон отправляет сообщение через <k>SendAddonMessage</k>. Другой аддон с таким же префиксом получает его через событие <k>CHAT_MSG_ADDON</k>.</t>
<code>
-- Отправка
SendAddonMessage("MyPrefix", "Hello", "GUILD")
-- Получение (в другом аддоне или у другого игрока)
-- Событие CHAT_MSG_ADDON с prefix = "MyPrefix"
</code>
<h>RegisterAddonMessagePrefix</h>
<t>Перед получением сообщений нужно зарегистрировать префикс:</t>
<code>
RegisterAddonMessagePrefix("MyPrefix")
</code>
<t>Без регистрации событие <k>CHAT_MSG_ADDON</k> не придёт для этого префикса.</t>
<h>SendAddonMessage</h>
<code>
SendAddonMessage(prefix, message, channel, target)
</code>
<t>Аргументы:</t>
<c>prefix</c> — строка-префикс, идентификатор аддона.
<c>message</c> — текст сообщения.
<c>channel</c> — канал отправки.
<c>target</c> — имя получателя (только для канала "WHISPER").
<h>Каналы отправки</h>
<c>"GUILD"</c> — всем членам гильдии.
<c>"PARTY"</c> — всем членам группы.
<c>"RAID"</c> — всем членам рейда.
<c>"WHISPER"</c> — конкретному игроку (нужен аргумент target).
<c>"BATTLEGROUND"</c> — всем на поле боя.
<h>Пример отправки</h>
<code>
/run RegisterAddonMessagePrefix("NSCourse")
/run SendAddonMessage("NSCourse", "ping", "GUILD")
</code>
<h>Пример получения</h>
<code>
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if prefix == "NSCourse" then
        print("От " .. sender .. ": " .. message)
    end
end)
</code>
<h>Ограничения</h>
<w>Важно:</w> в WoW 3.3.5 максимальная длина сообщения ограничена. Префикс и сообщение вместе не должны превышать <n>255</n> байт.
<t>Если сообщение длинное, его нужно разбивать на части и отправлять по очереди.</t>
<h>Формат данных</h>
<t>Сообщение — это просто строка. Для передачи структурированных данных используют разделение символом:</t>
<code>
local data = "key1:value1|key2:value2"
SendAddonMessage("MyPrefix", data, "GUILD")
</code>
<t>Или сериализацию в строку:</t>
<code>
local msg = table.concat({"hp", "100", "mana", "50"}, ",")
SendAddonMessage("MyPrefix", msg, "PARTY")
</code>
<h>Безопасный шаблон</h>
<code>
local function SafeSendAddonMessage(prefix, message, channel)
    if type(prefix) ~= "string" or prefix == "" then
        return false
    end
    if type(message) ~= "string" then
        return false
    end
    if type(channel) ~= "string" or channel == "" then
        return false
    end
    SendAddonMessage(prefix, message, channel)
    return true
end
</code>
<w>Примечание:</w> сообщения аддонов не видны в чате игрока. Они передаются только между аддонами.
]=],
}

ns_llua['lua'][342] = {
type = "vartest",
title = "Тест: префикс и каналы",
helpModules = {341},
tasks = {
{
var = "addonPrefix",
desc = 'Создай глобальную переменную addonPrefix = "NSCourse"',
check = function(value)
return type(value) == "string" and value == "NSCourse"
end,
},
{
var = "addonChannelGuild",
desc = 'Создай глобальную переменную addonChannelGuild = "GUILD"',
check = function(value)
return type(value) == "string" and value == "GUILD"
end,
},
{
var = "addonChannelParty",
desc = 'Создай глобальную переменную addonChannelParty = "PARTY"',
check = function(value)
return type(value) == "string" and value == "PARTY"
end,
},
},
}

ns_llua['lua'][343] = {
type = "vartest",
title = "Тест: формат сообщения",
helpModules = {341, 33, 31},
tasks = {
{
var = "addonMessageData",
desc = 'Создай глобальную переменную addonMessageData: объедини строки "hp", "100", "mana", "50" через запятую с помощью table.concat',
check = function(value)
return type(value) == "string" and value == "hp,100,mana,50"
end,
},
{
var = "addonMessageLength",
desc = 'Создай глобальную переменную addonMessageLength: длина строки addonMessageData (используй оператор #)',
check = function(value)
return type(value) == "number" and value == 14
end,
},
},
}

ns_llua['lua'][344] = {
type = "commenttest",
title = "Тест: функция BuildAddonMessage",
helpModules = {341, 45, 31, 44},
preloadVars = {
{var = "BuildAddonMessage", desc = "BuildAddonMessage очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 317-3: функция BuildAddonMessage</h>
<t>Создай глобальную функцию <k>BuildAddonMessage(data)</k>.</t>
<t>Аргумент <k>data</k> — это таблица-массив со строками.</t>
<t>Если <k>data</k> не является таблицей, функция должна вернуть пустую строку <s>""</s>.</t>
<t>Иначе функция должна объединить все элементы таблицы через запятую с помощью:</t>
<code>
table.concat(data, ",")
</code>
<t>Если результат не является строкой, функция должна вернуть пустую строку <s>""</s>.</t>
<t>Иначе функция должна вернуть полученную строку.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию BuildAddonMessage(data)
]=],
requireKeywords = {
"BuildAddonMessage",
"function",
"table.concat",
"type",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.BuildAddonMessage) ~= "function" then
_G.checkError = "BuildAddonMessage не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.BuildAddonMessage, {"hp", "100", "mana", "50"})
if not ok1 then
_G.checkError = "Ошибка вызова BuildAddonMessage: " .. tostring(result1)
return false
end
if result1 ~= "hp,100,mana,50" then
_G.checkError = "Для таблицы {hp, 100, mana, 50} функция должна вернуть 'hp,100,mana,50'"
return false
end
local ok2, result2 = pcall(_G.BuildAddonMessage, {})
if not ok2 or result2 ~= "" then
_G.checkError = "Для пустой таблицы функция должна вернуть пустую строку"
return false
end
local ok3, result3 = pcall(_G.BuildAddonMessage, "bad")
if not ok3 or result3 ~= "" then
_G.checkError = "Для не-таблицы функция должна вернуть пустую строку"
return false
end
local ok4, result4 = pcall(_G.BuildAddonMessage, {"one"})
if not ok4 or result4 ~= "one" then
_G.checkError = "Для таблицы с одним элементом функция должна вернуть этот элемент"
return false
end
return true
end,
}

ns_llua['lua'][345] = {
type = "commenttest",
title = "Тест: функция SplitLongMessage",
helpModules = {341, 45, 31, 33, 10},
preloadVars = {
{var = "SplitLongMessage", desc = "SplitLongMessage очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 317-4: функция SplitLongMessage</h>
<t>Создай глобальную функцию <k>SplitLongMessage(message, maxLen)</k>.</t>
<t>Если <k>message</k> не является строкой, функция должна вернуть пустую таблицу <k>{}</k>.</t>
<t>Если <k>maxLen</k> не является числом или меньше либо равно нуля, функция должна вернуть пустую таблицу <k>{}</k>.</t>
<t>Иначе функция должна разбить строку <k>message</k> на части длиной не более <k>maxLen</k> символов каждая.</t>
<t>Результат — таблица-массив со строками-частями.</t>
<t>Используй:</t>
<c>string.sub</c>
<c>table.insert</c>
<c>цикл while или for</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию SplitLongMessage(message, maxLen)
]=],
requireKeywords = {
"SplitLongMessage",
"function",
"string.sub",
"table.insert",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.SplitLongMessage) ~= "function" then
_G.checkError = "SplitLongMessage не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.SplitLongMessage, "abcdefghij", 3)
if not ok1 then
_G.checkError = "Ошибка вызова SplitLongMessage: " .. tostring(result1)
return false
end
if type(result1) ~= "table" then
_G.checkError = "Функция должна вернуть таблицу"
return false
end
if #result1 ~= 4 then
_G.checkError = "Строка 'abcdefghij' с maxLen=3 должна дать 4 части"
return false
end
if result1[1] ~= "abc" or result1[2] ~= "def" or result1[3] ~= "ghi" or result1[4] ~= "j" then
_G.checkError = "Части строки разбиты неверно"
return false
end
local ok2, result2 = pcall(_G.SplitLongMessage, "", 5)
if not ok2 or type(result2) ~= "table" or #result2 ~= 0 then
_G.checkError = "Для пустой строки функция должна вернуть пустую таблицу"
return false
end
local ok3, result3 = pcall(_G.SplitLongMessage, 123, 5)
if not ok3 or type(result3) ~= "table" or #result3 ~= 0 then
_G.checkError = "Для не-строки функция должна вернуть пустую таблицу"
return false
end
local ok4, result4 = pcall(_G.SplitLongMessage, "test", 0)
if not ok4 or type(result4) ~= "table" or #result4 ~= 0 then
_G.checkError = "Для maxLen=0 функция должна вернуть пустую таблицу"
return false
end
return true
end,
}

ns_llua['lua'][346] = {
type = "commenttest",
title = "Тест: функция ParseAddonMessage",
helpModules = {341, 45, 33, 31, 44},
preloadVars = {
{var = "ParseAddonMessage", desc = "ParseAddonMessage очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 317-5: функция ParseAddonMessage</h>
<t>Создай глобальную функцию <k>ParseAddonMessage(message)</k>.</t>
<t>Если <k>message</k> не является строкой или является пустой строкой, функция должна вернуть пустую таблицу <k>{}</k>.</t>
<t>Иначе функция должна разбить строку по запятым и вернуть таблицу-массив с частями.</t>
<t>Например, строка <s>"hp,100,mana,50"</s> должна дать таблицу:</t>
<code>
{"hp", "100", "mana", "50"}
</code>
<t>Используй:</t>
<c>string.gmatch</c> или <c>string.find</c>
<c>table.insert</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию ParseAddonMessage(message)
]=],
requireKeywords = {
"ParseAddonMessage",
"function",
"table.insert",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.ParseAddonMessage) ~= "function" then
_G.checkError = "ParseAddonMessage не является глобальной функцией"
return false
end
local ok1, result1 = pcall(_G.ParseAddonMessage, "hp,100,mana,50")
if not ok1 then
_G.checkError = "Ошибка вызова ParseAddonMessage: " .. tostring(result1)
return false
end
if type(result1) ~= "table" then
_G.checkError = "Функция должна вернуть таблицу"
return false
end
if #result1 ~= 4 then
_G.checkError = "Строка 'hp,100,mana,50' должна дать 4 элемента"
return false
end
if result1[1] ~= "hp" or result1[2] ~= "100" or result1[3] ~= "mana" or result1[4] ~= "50" then
_G.checkError = "Элементы таблицы неверны"
return false
end
local ok2, result2 = pcall(_G.ParseAddonMessage, "")
if not ok2 or type(result2) ~= "table" or #result2 ~= 0 then
_G.checkError = "Для пустой строки функция должна вернуть пустую таблицу"
return false
end
local ok3, result3 = pcall(_G.ParseAddonMessage, 123)
if not ok3 or type(result3) ~= "table" or #result3 ~= 0 then
_G.checkError = "Для не-строки функция должна вернуть пустую таблицу"
return false
end
local ok4, result4 = pcall(_G.ParseAddonMessage, "single")
if not ok4 or type(result4) ~= "table" or #result4 ~= 1 or result4[1] ~= "single" then
_G.checkError = "Для строки без запятых функция должна вернуть таблицу с одним элементом"
return false
end
return true
end,
}

ns_llua['lua'][347] = {
type = "info",
title = "Защищённый код и InCombatLockdown",
helpModules = {239, 89, 215},
content = [=[
<h>Защищённый код и InCombatLockdown</h>
<t>В WoW есть механизм защиты интерфейса. Когда игрок находится в бою, некоторые действия с фреймами блокируются. Это сделано для того, чтобы аддоны не могли автоматически атаковать, кастовать или менять поведение кнопок без участия игрока.</t>
<h>InCombatLockdown</h>
<t>Функция <k>InCombatLockdown()</k> проверяет, находится ли интерфейс в состоянии блокировки боя.</t>
<code>
/run print(InCombatLockdown())
</code>
<w>Важно:</w> в WoW 3.3.5 функция возвращает <k>1</k> или <k>nil</k>, а не <k>true</k> / <k>false</k>. Для приведения к boolean используй <k>not not</k> или <k>and true or false</k>.
<h>Что блокируется в бою</h>
<t>В состоянии блокировки нельзя:</t>
<c>Менять атрибуты protected-фреймов</c>
<c>Создавать или удалять secure-фреймы</c>
<c>Менять макросы</c>
<c>Вызывать некоторые функции UI</c>
<h>UnitAffectingCombat</h>
<t>Альтернативный способ проверить, в бою ли юнит:</t>
<code>
/run print(UnitAffectingCombat("player"))
</code>
<t>Эта функция проверяет конкретного юнита, а не состояние интерфейса.</t>
<h>Разница между InCombatLockdown и UnitAffectingCombat</h>
<c>InCombatLockdown()</c> — состояние интерфейса. Блокирует изменение protected-фреймов.
<c>UnitAffectingCombat("player")</c> — состояние юнита. Показывает, атакует ли юнит.
<t>Обычно они совпадают, но не всегда. Например, интерфейс может быть в блокировке ещё короткое время после выхода из боя.</t>
<h>CanChangeProtectedState</h>
<code>
/run print(CanChangeProtectedState())
</code>
<t>Функция проверяет, можно ли сейчас менять protected-фреймы. Возвращает истинное значение, если можно.</t>
<h>События боя</h>
<t>Для отслеживания входа и выхода из боя используются события:</t>
<c>PLAYER_REGEN_DISABLED</c> — игрок вошёл в бой.
<c>PLAYER_REGEN_ENABLED</c> — игрок вышел из боя.
<code>
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        print("Вошёл в бой")
    elseif event == "PLAYER_REGEN_ENABLED" then
        print("Вышел из боя")
    end
end)
</code>
<h>Отложенные действия</h>
<t>Если действие нельзя выполнить в бою, его можно отложить до выхода из боя:</t>
<code>
local pendingAction = nil
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" and pendingAction then
        pendingAction()
        pendingAction = nil
    end
end)
</code>
<h>Безопасный шаблон</h>
<code>
/run local inLockdown = InCombatLockdown() and true or false; print("Блокировка: " .. tostring(inLockdown))
</code>
]=],
}

ns_llua['lua'][348] = {
type = "vartest",
title = "Тест: InCombatLockdown и UnitAffectingCombat",
helpModules = {347, 15},
tasks = {
{
var = "inCombatLockdown",
desc = 'Создай глобальную переменную inCombatLockdown = not not InCombatLockdown()',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "playerInCombat",
desc = 'Создай глобальную переменную playerInCombat = not not UnitAffectingCombat("player")',
check = function(value)
return type(value) == "boolean"
end,
},
},
}

ns_llua['lua'][349] = {
type = "vartest",
title = "Тест: CanChangeProtectedState",
helpModules = {347, 15},
tasks = {
{
var = "canChangeProtected",
desc = 'Создай глобальную переменную canChangeProtected = not not CanChangeProtectedState()',
check = function(value)
return type(value) == "boolean"
end,
},
{
var = "lockdownOrCombat",
desc = 'Создай глобальную переменную lockdownOrCombat = (not not InCombatLockdown()) or (not not UnitAffectingCombat("player"))',
check = function(value)
return type(value) == "boolean"
end,
},
},
}

ns_llua['lua'][350] = {
type = "commenttest",
title = "Тест: функция IsInCombatLockdownSafe",
helpModules = {347, 45, 21},
preloadVars = {
{var = "IsInCombatLockdownSafe", desc = "IsInCombatLockdownSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 323-3: функция IsInCombatLockdownSafe</h>
<t>Создай глобальную функцию <k>IsInCombatLockdownSafe()</k>.</t>
<t>Функция должна вернуть <k>true</k>, если интерфейс находится в состоянии блокировки боя.</t>
<t>Иначе функция должна вернуть <k>false</k>.</t>
<t>Используй:</t>
<c>InCombatLockdown()</c>
<t>Чтобы результат был именно boolean, используй конструкцию:</t>
<code>
return InCombatLockdown() and true or false
</code>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию IsInCombatLockdownSafe()
]=],
requireKeywords = {
"IsInCombatLockdownSafe",
"function",
"InCombatLockdown",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.IsInCombatLockdownSafe) ~= "function" then
_G.checkError = "IsInCombatLockdownSafe не является глобальной функцией"
return false
end
local ok, result = pcall(_G.IsInCombatLockdownSafe)
if not ok then
_G.checkError = "Ошибка вызова IsInCombatLockdownSafe: " .. tostring(result)
return false
end
if type(result) ~= "boolean" then
_G.checkError = "Функция должна вернуть boolean"
return false
end
local expected = InCombatLockdown() and true or false
if result ~= expected then
_G.checkError = "Результат не совпадает с текущим состоянием InCombatLockdown()"
return false
end
return true
end,
}

ns_llua['lua'][351] = {
type = "commenttest",
title = "Тест: функция CanModifyFrameSafe",
helpModules = {347, 45, 21},
preloadVars = {
{var = "CanModifyFrameSafe", desc = "CanModifyFrameSafe очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 323-4: функция CanModifyFrameSafe</h>
<t>Создай глобальную функцию <k>CanModifyFrameSafe(frame)</k>.</t>
<t>Если <k>frame</k> не существует или у него нет метода <k>IsProtected</k>, функция должна вернуть <k>false</k>.</t>
<t>Если фрейм не является protected, функция должна вернуть <k>true</k>.</t>
<t>Если фрейм является protected, функция должна проверить, можно ли менять protected-фреймы через:</t>
<code>
CanChangeProtectedState()
</code>
<t>Если можно, верни <k>true</k>. Иначе верни <k>false</k>.</t>
<t>Используй:</t>
<c>frame:IsProtected()</c>
<c>CanChangeProtectedState()</c>
<t>Для boolean-значений используй приведение через <k>and true or false</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CanModifyFrameSafe(frame)
]=],
requireKeywords = {
"CanModifyFrameSafe",
"function",
"IsProtected",
"CanChangeProtectedState",
"and",
"or",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CanModifyFrameSafe) ~= "function" then
_G.checkError = "CanModifyFrameSafe не является глобальной функцией"
return false
end
-- Тест 1: обычный фрейм без защиты
local normalFrame = CreateFrame("Frame", nil, UIParent)
local ok1, result1 = pcall(_G.CanModifyFrameSafe, normalFrame)
if not ok1 then
_G.checkError = "Ошибка вызова CanModifyFrameSafe с обычным фреймом: " .. tostring(result1)
return false
end
if result1 ~= true then
_G.checkError = "Для обычного фрейма функция должна вернуть true"
return false
end
-- Тест 2: nil
local ok2, result2 = pcall(_G.CanModifyFrameSafe, nil)
if not ok2 or result2 ~= false then
_G.checkError = "Для nil функция должна вернуть false"
return false
end
-- Тест 3: пустая таблица
local ok3, result3 = pcall(_G.CanModifyFrameSafe, {})
if not ok3 or result3 ~= false then
_G.checkError = "Для пустой таблицы функция должна вернуть false"
return false
end
return true
end,
}

ns_llua['lua'][352] = {
type = "commenttest",
title = "Тест: функция DeferredAction",
helpModules = {347, 45, 239},
preloadVars = {
{var = "DeferredAction", desc = "DeferredAction очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
{var = "deferredExecuted", desc = "deferredExecuted очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 323-5: функция DeferredAction</h>
<t>Создай глобальную функцию <k>DeferredAction(callback)</k>.</t>
<t>Если <k>callback</k> не является функцией, функция должна вернуть <k>false</k>.</t>
<t>Если интерфейс НЕ находится в состоянии блокировки боя, функция должна немедленно вызвать <k>callback()</k> и вернуть <k>true</k>.</t>
<t>Если интерфейс находится в состоянии блокировки боя, функция должна сохранить <k>callback</k> в глобальную переменную <k>pendingCallback</k> и вернуть <k>true</k>.</t>
<t>Используй:</t>
<c>InCombatLockdown()</c>
<c>pendingCallback</c>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию DeferredAction(callback)
]=],
requireKeywords = {
"DeferredAction",
"function",
"InCombatLockdown",
"pendingCallback",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.DeferredAction) ~= "function" then
_G.checkError = "DeferredAction не является глобальной функцией"
return false
end
-- Тест 1: не функция
local ok1, result1 = pcall(_G.DeferredAction, "bad")
if not ok1 or result1 ~= false then
_G.checkError = "Для не-функции функция должна вернуть false"
return false
end
-- Тест 2: корректная функция вне боя
_G.deferredExecuted = false
local testCallback = function()
_G.deferredExecuted = true
end
local ok2, result2 = pcall(_G.DeferredAction, testCallback)
if not ok2 then
_G.checkError = "Ошибка вызова DeferredAction: " .. tostring(result2)
return false
end
if result2 ~= true then
_G.checkError = "Для корректной функции DeferredAction должна вернуть true"
return false
end
-- Если мы не в бою, callback должна была выполниться
local inLockdown = InCombatLockdown() and true or false
if not inLockdown then
if _G.deferredExecuted ~= true then
_G.checkError = "Вне боя callback должна была выполниться немедленно"
return false
end
else
-- В бою callback не должна была выполниться, но pendingCallback должна быть установлена
if type(_G.pendingCallback) ~= "function" then
_G.checkError = "В бою callback должна быть сохранена в pendingCallback"
return false
end
end
return true
end,
}

ns_llua['lua'][353] = {
type = "info",
title = "Продвинутые баффы: фильтрация по кастеру",
helpModules = {107, 203, 65},
content = [=[
<h>Продвинутые баффы: фильтрация по кастеру</h>
<t>Раньше мы считали все баффы и дебаффы подряд. Теперь научимся фильтровать ауры по тому, кто их наложил.</t>
<h>UnitAura с фильтром</h>
<t>Функция <k>UnitAura</k> принимает третий аргумент — строку-фильтр.</t>
<code>
/run local name = UnitAura("player", 1, "HELPFUL"); print(name or "нет")
</code>
<h>Основные фильтры</h>
<c>"HELPFUL"</c> — только баффы.
<c>"HARMFUL"</c> — только дебаффы.
<c>"PLAYER"</c> — только ауры, наложенные игроком.
<h>Комбинация фильтров</h>
<t>Фильтры можно комбинировать через символ <k>|</k>.</t>
<code>
/run local name = UnitAura("player", 1, "HELPFUL|PLAYER"); print(name or "нет")
</code>
<t>Это вернёт только баффы, которые наложил сам игрок.</t>
<code>
/run local name = UnitAura("target", 1, "HARMFUL|PLAYER"); print(name or "нет")
</code>
<t>Это вернёт только дебаффы на цели, которые наложил сам игрок.</t>
<h>Кто наложил ауру</h>
<t>Функция <k>UnitAura</k> возвращает много значений. Восьмое значение — <k>unitCaster</k>, UnitID того, кто наложил ауру.</t>
<code>
/run local name, _, _, _, _, _, _, caster = UnitAura("player", 1, "HELPFUL"); print(name or "нет", caster or "неизвестно")
</code>
<t>Если ауру наложил сам игрок, <k>caster</k> будет равен <s>"player"</s>.</t>
<h>Подсчёт своих баффов</h>
<code>
/run local count = 0; for i = 1, 40 do local name = UnitAura("player", i, "HELPFUL|PLAYER"); if not name then break end; count = count + 1 end; print("Мои баффы: " .. count)
</code>
<h>Подсчёт своих дебаффов на цели</h>
<code>
/run local count = 0; for i = 1, 40 do local name = UnitAura("target", i, "HARMFUL|PLAYER"); if not name then break end; count = count + 1 end; print("Мои дебаффы на цели: " .. count)
</code>
<h>Проверка кастера вручную</h>
<t>Если нужна более тонкая проверка, можно получить <k>unitCaster</k> и сравнить его.</t>
<code>
/run local name, _, _, _, _, _, _, caster = UnitAura("player", 1, "HELPFUL"); if name and caster == "player" then print("Мой бафф: " .. name) end
</code>
<h>Фильтр CANCELABLE и NOT_CANCELABLE</h>
<t>В некоторых версиях WoW доступны дополнительные фильтры:</t>
<c>"CANCELABLE"</c> — ауры, которые можно отменить.
<c>"NOT_CANCELABLE"</c> — ауры, которые нельзя отменить.
<w>Примечание:</w> в WoW 3.3.5 поддержка этих фильтров может отличаться. Проверяй через <k>/dump</k>.
<h>Безопасный шаблон</h>
<code>
/run local count = 0; for i = 1, 40 do local name = UnitAura("player", i, "HELPFUL|PLAYER"); if not name then break end; count = count + 1 end; print(string.format("Своих баффов: %d", count))
</code>
]=],
}

ns_llua['lua'][354] = {
type = "vartest",
title = "Тест: фильтры аур",
helpModules = {353},
tasks = {
{
var = "filterHelpfulPlayer",
desc = 'Создай глобальную переменную filterHelpfulPlayer = "HELPFUL|PLAYER"',
check = function(value)
return value == "HELPFUL|PLAYER"
end,
},
{
var = "filterHarmfulPlayer",
desc = 'Создай глобальную переменную filterHarmfulPlayer = "HARMFUL|PLAYER"',
check = function(value)
return value == "HARMFUL|PLAYER"
end,
},
},
}

ns_llua['lua'][355] = {
type = "vartest",
title = "Тест: первый бафф игрока и его кастер",
helpModules = {353, 203, 65},
tasks = {
{
var = "firstBuffCaster",
desc = 'Создай глобальную переменную firstBuffCaster = select(8, UnitAura("player", 1, "HELPFUL")) or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
{
var = "firstMyBuffName",
desc = 'Создай глобальную переменную firstMyBuffName = UnitAura("player", 1, "HELPFUL|PLAYER") or "нет"',
check = function(value)
return type(value) == "string" and value ~= ""
end,
},
},
}

ns_llua['lua'][356] = {
type = "commenttest",
title = "Тест: функция CountMyBuffs",
helpModules = {353, 203, 45, 31},
preloadVars = {
{var = "CountMyBuffs", desc = "CountMyBuffs очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 329-3: функция CountMyBuffs</h>
<t>Создай глобальную функцию <k>CountMyBuffs(unit)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна посчитать количество баффов на юните, которые наложил сам игрок.</t>
<t>Используй:</t>
<code>
UnitAura(unit, index, "HELPFUL|PLAYER")
</code>
<t>Проверяй индексы от 1 до 40.</t>
<t>Если <k>UnitAura</k> вернул <k>nil</k>, прекрати подсчёт.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountMyBuffs(unit)
]=],
requireKeywords = {
"CountMyBuffs",
"function",
"UnitAura",
"HELPFUL",
"PLAYER",
"for",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountMyBuffs) ~= "function" then
_G.checkError = "CountMyBuffs не является глобальной функцией"
return false
end
local function countExpected(unit)
if type(unit) ~= "string" then
return 0
end
local count = 0
for i = 1, 40 do
if not UnitAura(unit, i, "HELPFUL|PLAYER") then
break
end
count = count + 1
end
return count
end
local expected1 = countExpected("player")
local ok1, result1 = pcall(_G.CountMyBuffs, "player")
if not ok1 then
_G.checkError = "Ошибка вызова CountMyBuffs('player'): " .. tostring(result1)
return false
end
if result1 ~= expected1 then
_G.checkError = "Для player функция вернула неверное количество своих баффов"
return false
end
local ok2, result2 = pcall(_G.CountMyBuffs, "ns_invalid_unit")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.CountMyBuffs, 123)
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нестрокового unit функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][357] = {
type = "commenttest",
title = "Тест: функция CountMyDebuffs",
helpModules = {353, 203, 45, 31},
preloadVars = {
{var = "CountMyDebuffs", desc = "CountMyDebuffs очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 329-4: функция CountMyDebuffs</h>
<t>Создай глобальную функцию <k>CountMyDebuffs(unit)</k>.</t>
<t>Если <k>unit</k> не является строкой, функция должна вернуть <n>0</n>.</t>
<t>Иначе функция должна посчитать количество дебаффов на юните, которые наложил сам игрок.</t>
<t>Используй:</t>
<code>
UnitAura(unit, index, "HARMFUL|PLAYER")
</code>
<t>Проверяй индексы от 1 до 40.</t>
<t>Если <k>UnitAura</k> вернул <k>nil</k>, прекрати подсчёт.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию CountMyDebuffs(unit)
]=],
requireKeywords = {
"CountMyDebuffs",
"function",
"UnitAura",
"HARMFUL",
"PLAYER",
"for",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.CountMyDebuffs) ~= "function" then
_G.checkError = "CountMyDebuffs не является глобальной функцией"
return false
end
local function countExpected(unit)
if type(unit) ~= "string" then
return 0
end
local count = 0
for i = 1, 40 do
if not UnitAura(unit, i, "HARMFUL|PLAYER") then
break
end
count = count + 1
end
return count
end
local expected1 = countExpected("player")
local ok1, result1 = pcall(_G.CountMyDebuffs, "player")
if not ok1 then
_G.checkError = "Ошибка вызова CountMyDebuffs('player'): " .. tostring(result1)
return false
end
if result1 ~= expected1 then
_G.checkError = "Для player функция вернула неверное количество своих дебаффов"
return false
end
local ok2, result2 = pcall(_G.CountMyDebuffs, "ns_invalid_unit")
if not ok2 or result2 ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть 0"
return false
end
local ok3, result3 = pcall(_G.CountMyDebuffs, 123)
if not ok3 or result3 ~= 0 then
_G.checkError = "Для нестрокового unit функция должна вернуть 0"
return false
end
return true
end,
}

ns_llua['lua'][358] = {
type = "commenttest",
title = "Тест: функция GetMyAuraList",
helpModules = {353, 203, 45, 31, 44},
preloadVars = {
{var = "GetMyAuraList", desc = "GetMyAuraList очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Тест 329-5: функция GetMyAuraList</h>
<t>Создай глобальную функцию <k>GetMyAuraList(unit, filter)</k>.</t>
<t>Если <k>unit</k> не является строкой или <k>filter</k> не является строкой, функция должна вернуть пустую таблицу <k>{}</k>.</t>
<t>Иначе функция должна собрать таблицу-массив с именами аур юнита, которые подходят под фильтр.</t>
<t>Используй:</t>
<code>
UnitAura(unit, index, filter)
</code>
<t>Проверяй индексы от 1 до 40.</t>
<t>Если <k>UnitAura</k> вернул <k>nil</k>, прекрати перебор.</t>
<t>Добавляй только непустые строки через <k>table.insert</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальную функцию GetMyAuraList(unit, filter)
]=],
requireKeywords = {
"GetMyAuraList",
"function",
"UnitAura",
"table.insert",
"for",
"return",
},
checkCode = function()
_G.checkError = nil
if type(_G.GetMyAuraList) ~= "function" then
_G.checkError = "GetMyAuraList не является глобальной функцией"
return false
end
local function buildExpected(unit, filter)
if type(unit) ~= "string" or type(filter) ~= "string" then
return {}
end
local list = {}
for i = 1, 40 do
local name = UnitAura(unit, i, filter)
if not name then
break
end
if type(name) == "string" and name ~= "" then
table.insert(list, name)
end
end
return list
end
-- Тест 1: баффы игрока, наложенные игроком
local expected1 = buildExpected("player", "HELPFUL|PLAYER")
local ok1, result1 = pcall(_G.GetMyAuraList, "player", "HELPFUL|PLAYER")
if not ok1 then
_G.checkError = "Ошибка вызова GetMyAuraList('player', 'HELPFUL|PLAYER'): " .. tostring(result1)
return false
end
if type(result1) ~= "table" then
_G.checkError = "Функция должна вернуть таблицу"
return false
end
if #result1 ~= #expected1 then
_G.checkError = "Количество аур не совпадает с ожидаемым"
return false
end
for i = 1, #expected1 do
if result1[i] ~= expected1[i] then
_G.checkError = "Элемент " .. i .. " не совпадает с ожидаемым"
return false
end
end
-- Тест 2: несуществующий юнит
local ok2, result2 = pcall(_G.GetMyAuraList, "ns_invalid_unit", "HELPFUL|PLAYER")
if not ok2 or type(result2) ~= "table" or #result2 ~= 0 then
_G.checkError = "Для несуществующего юнита функция должна вернуть пустую таблицу"
return false
end
-- Тест 3: нестроковый фильтр
local ok3, result3 = pcall(_G.GetMyAuraList, "player", 123)
if not ok3 or type(result3) ~= "table" or #result3 ~= 0 then
_G.checkError = "Для нестрокового фильтра функция должна вернуть пустую таблицу"
return false
end
-- Тест 4: нестроковый unit
local ok4, result4 = pcall(_G.GetMyAuraList, 123, "HELPFUL|PLAYER")
if not ok4 or type(result4) ~= "table" or #result4 ~= 0 then
_G.checkError = "Для нестрокового unit функция должна вернуть пустую таблицу"
return false
end
return true
end,
}

ns_llua['lua'][359] = {
type = "info",
title = "Финальный проект: мини-аддон",
helpModules = {215, 221, 227, 257, 263, 269},
content = [=[
<h>Финальный проект: мини-аддон</h>
<t>Пришло время собрать все знания курса в один практический проект.</t>
<t>Мы создадим простой информационный аддон — панель персонажа. Она будет показывать:</t>
<c>Имя, уровень и класс игрока</c>
<c>Здоровье и ресурс</c>
<c>Координаты на карте</c>
<c>Кнопку обновления данных</c>
<t>Аддон будет обновляться по событию <k>PLAYER_TARGET_CHANGED</k> и по клику на кнопку.</t>
<h>Структура проекта</h>
<t>Проект состоит из пяти шагов:</t>
<c>Шаг 1</c> — создание основного фрейма.
<c>Шаг 2</c> — добавление текста с данными.
<c>Шаг 3</c> — добавление кнопки обновления.
<c>Шаг 4</c> — привязка событий.
<c>Шаг 5</c> — финальная сборка и проверка.
<h>Что мы используем</h>
<t>Из предыдущих модулей курса:</t>
<c>CreateFrame</c> — создание фреймов.
<c>SetSize, SetPoint</c> — размер и позиция.
<c>CreateFontString</c> — текст.
<c>SetScript("OnClick", ...)</c> — обработчик клика.
<c>RegisterEvent, SetScript("OnEvent", ...)</c> — события.
<c>UnitName, UnitLevel, UnitClass</c> — данные игрока.
<c>UnitHealth, UnitHealthMax</c> — здоровье.
<c>GetPlayerMapPosition</c> — координаты.
<h>Глобальные переменные проекта</h>
<t>Для проверки система будет искать следующие глобальные переменные:</t>
<c>NSPanelFrame</c> — основной фрейм.
<c>NSPanelTitle</c> — FontString с заголовком.
<c>NSPanelInfo</c> — FontString с информацией.
<c>NSPanelButton</c> — кнопка обновления.
<c>NSPanelUpdate</c> — функция обновления данных.
<c>NSPanelEventFrame</c> — фрейм для событий.
<w>Важно:</w> все переменные должны быть глобальными (без <k>local</k>), чтобы система могла их проверить.
<h>Совет</h>
<t>Выполняй шаги по порядку. Каждый шаг проверяется отдельно. Если шаг не проходится, вернись и исправь ошибку перед тем, как идти дальше.</t>
]=],
}

ns_llua['lua'][360] = {
type = "commenttest",
title = "Проект шаг 1: основной фрейм",
helpModules = {359, 215, 221},
preloadVars = {
{var = "NSPanelFrame", desc = "NSPanelFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Проект шаг 1: основной фрейм</h>
<t>Создай глобальный фрейм <k>NSPanelFrame</k>.</t>
<t>Требования:</t>
<t>- тип фрейма: <s>"Frame"</s>;</t>
<t>- глобальное имя: <s>"NSPanelFrame"</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- размер: 280 на 200;</t>
<t>- позиция: <k>SetPoint("CENTER")</k>;</t>
<t>- слой: <k>SetFrameStrata("HIGH")</k>;</t>
<t>- фрейм должен быть показан через <k>Show()</k>.</t>
<t>Ничего выводить не нужно.</t>
]=],
initialCode = [=[
-- Создай глобальный фрейм NSPanelFrame
]=],
requireKeywords = {
"NSPanelFrame",
"CreateFrame",
"Frame",
"UIParent",
"SetSize",
"SetPoint",
"SetFrameStrata",
"Show",
},
checkCode = function()
_G.checkError = nil
local f = _G.NSPanelFrame
if not f then
_G.checkError = "NSPanelFrame не был создан"
return false
end
if type(f.IsShown) ~= "function" then
_G.checkError = "NSPanelFrame не похож на фрейм"
return false
end
if not f:IsShown() then
_G.checkError = "Фрейм должен быть показан"
return false
end
if f:GetWidth() ~= 280 then
_G.checkError = "Ширина фрейма должна быть 280"
return false
end
if f:GetHeight() ~= 200 then
_G.checkError = "Высота фрейма должна быть 200"
return false
end
if type(f.GetFrameStrata) ~= "function" or f:GetFrameStrata() ~= "HIGH" then
_G.checkError = "Фрейм должен иметь слой HIGH"
return false
end
return true
end,
}

ns_llua['lua'][361] = {
type = "commenttest",
title = "Проект шаг 2: текст с данными",
helpModules = {359, 227, 53, 83, 7},
preloadVars = {
{var = "NSPanelFrame", desc = "NSPanelFrame очищается перед проверкой"},
{var = "NSPanelTitle", desc = "NSPanelTitle очищается перед проверкой"},
{var = "NSPanelInfo", desc = "NSPanelInfo очищается перед проверкой"},
{var = "NSPanelUpdate", desc = "NSPanelUpdate очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Проект шаг 2: текст с данными</h>
<t>Сначала создай фрейм <k>NSPanelFrame</k> (если ещё не создан):</t>
<t>- тип <s>"Frame"</s>, родитель <k>UIParent</k>, размер 280 на 200, позиция CENTER, показан.</t>
<t>Затем создай два FontString на этом фрейме:</t>
<t>1. Глобальная переменная <k>NSPanelTitle</k>:</t>
<t>- слой <s>"OVERLAY"</s>, шаблон <s>"GameFontNormalLarge"</s>;</t>
<t>- позиция: <k>SetPoint("TOP", 0, -10)</k>;</t>
<t>- текст: <s>"Панель персонажа"</s>.</t>
<t>2. Глобальная переменная <k>NSPanelInfo</k>:</t>
<t>- слой <s>"OVERLAY"</s>, шаблон <s>"GameFontNormal"</s>;</t>
<t>- позиция: <k>SetPoint("TOP", 0, -40)</k>;</t>
<t>- выравнивание: <k>SetJustifyH("LEFT")</k>;</t>
<t>- ширина: <k>SetWidth(260)</k>.</t>
<t>Затем создай глобальную функцию <k>NSPanelUpdate()</k>, которая:</t>
<t>- получает имя через <k>UnitName("player") or "Неизвестно"</k>;</t>
<t>- получает уровень через <k>UnitLevel("player") or 0</k>;</t>
<t>- получает здоровье через <k>UnitHealth("player") or 0</k> и <k>UnitHealthMax("player") or 0</k>;</t>
<t>- собирает строку через <k>string.format</k>;</t>
<t>- записывает её в <k>NSPanelInfo:SetText(...)</k>.</t>
<t>Вызови <k>NSPanelUpdate()</k> один раз после создания.</t>
<t>Ничего выводить через print не нужно.</t>
]=],
initialCode = [=[
-- Создай NSPanelFrame, NSPanelTitle, NSPanelInfo и NSPanelUpdate
]=],
requireKeywords = {
"NSPanelFrame",
"NSPanelTitle",
"NSPanelInfo",
"NSPanelUpdate",
"CreateFontString",
"SetText",
"UnitName",
"UnitLevel",
"UnitHealth",
"string.format",
},
checkCode = function()
_G.checkError = nil
local f = _G.NSPanelFrame
if not f or type(f.IsShown) ~= "function" then
_G.checkError = "NSPanelFrame не является фреймом"
return false
end
if not f:IsShown() then
_G.checkError = "NSPanelFrame должен быть показан"
return false
end
local title = _G.NSPanelTitle
if not title or type(title.SetText) ~= "function" then
_G.checkError = "NSPanelTitle не является FontString"
return false
end
if title:GetText() ~= "Панель персонажа" then
_G.checkError = "NSPanelTitle должен содержать текст 'Панель персонажа'"
return false
end
local info = _G.NSPanelInfo
if not info or type(info.SetText) ~= "function" then
_G.checkError = "NSPanelInfo не является FontString"
return false
end
if type(_G.NSPanelUpdate) ~= "function" then
_G.checkError = "NSPanelUpdate должна быть глобальной функцией"
return false
end
local ok, err = pcall(_G.NSPanelUpdate)
if not ok then
_G.checkError = "Ошибка вызова NSPanelUpdate: " .. tostring(err)
return false
end
local infoText = info:GetText()
if type(infoText) ~= "string" or infoText == "" then
_G.checkError = "NSPanelInfo должен содержать текст после вызова NSPanelUpdate"
return false
end
local playerName = UnitName("player")
if playerName and not infoText:find(playerName, 1, true) then
_G.checkError = "Текст NSPanelInfo должен содержать имя игрока"
return false
end
return true
end,
}

ns_llua['lua'][362] = {
type = "commenttest",
title = "Проект шаг 3: кнопка обновления",
helpModules = {359, 233, 227, 215},
preloadVars = {
{var = "NSPanelFrame", desc = "NSPanelFrame очищается перед проверкой"},
{var = "NSPanelInfo", desc = "NSPanelInfo очищается перед проверкой"},
{var = "NSPanelButton", desc = "NSPanelButton очищается перед проверкой"},
{var = "NSPanelUpdate", desc = "NSPanelUpdate очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Проект шаг 3: кнопка обновления</h>
<t>Сначала создай фрейм <k>NSPanelFrame</k> и FontString <k>NSPanelInfo</k> (если ещё не созданы).</t>
<t>Создай глобальную функцию <k>NSPanelUpdate()</k>, которая обновляет текст в <k>NSPanelInfo</k>.</t>
<t>Затем создай глобальную кнопку <k>NSPanelButton</k>:</t>
<t>- тип: <s>"Button"</s>;</t>
<t>- глобальное имя: <s>"NSPanelButton"</s>;</t>
<t>- родитель: <k>NSPanelFrame</k>;</t>
<t>- размер: 120 на 30;</t>
<t>- позиция: <k>SetPoint("BOTTOM", 0, 10)</k>;</t>
<t>- создай FontString для кнопки с текстом <s>"Обновить"</s>;</t>
<t>- назначь обработчик <k>OnClick</k>, который вызывает <k>NSPanelUpdate()</k>.</t>
<t>Ничего выводить через print не нужно.</t>
]=],
initialCode = [=[
-- Создай NSPanelFrame, NSPanelInfo, NSPanelUpdate и NSPanelButton
]=],
requireKeywords = {
"NSPanelFrame",
"NSPanelInfo",
"NSPanelButton",
"NSPanelUpdate",
"CreateFrame",
"Button",
"SetScript",
"OnClick",
},
checkCode = function()
_G.checkError = nil
local f = _G.NSPanelFrame
if not f or type(f.IsShown) ~= "function" then
_G.checkError = "NSPanelFrame не является фреймом"
return false
end
local info = _G.NSPanelInfo
if not info or type(info.SetText) ~= "function" then
_G.checkError = "NSPanelInfo не является FontString"
return false
end
if type(_G.NSPanelUpdate) ~= "function" then
_G.checkError = "NSPanelUpdate должна быть глобальной функцией"
return false
end
local btn = _G.NSPanelButton
if not btn or type(btn.GetScript) ~= "function" then
_G.checkError = "NSPanelButton не является кнопкой"
return false
end
if btn:GetWidth() ~= 120 or btn:GetHeight() ~= 30 then
_G.checkError = "Размер кнопки должен быть 120 на 30"
return false
end
local script = btn:GetScript("OnClick")
if type(script) ~= "function" then
_G.checkError = "У кнопки должен быть обработчик OnClick"
return false
end
-- Проверяем, что обработчик вызывает NSPanelUpdate
local oldText = info:GetText()
info:SetText("test_before_click")
local ok, err = pcall(script, btn, "LeftButton")
if not ok then
_G.checkError = "Ошибка при вызове OnClick: " .. tostring(err)
return false
end
local newText = info:GetText()
if newText == "test_before_click" then
_G.checkError = "OnClick должна вызывать NSPanelUpdate и менять текст"
return false
end
return true
end,
}

ns_llua['lua'][363] = {
type = "commenttest",
title = "Проект шаг 4: события",
helpModules = {359, 239, 215},
preloadVars = {
{var = "NSPanelEventFrame", desc = "NSPanelEventFrame очищается перед проверкой"},
{var = "NSPanelUpdate", desc = "NSPanelUpdate очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Проект шаг 4: события</h>
<t>Создай глобальную функцию <k>NSPanelUpdate()</k> (если ещё не создана).</t>
<t>Затем создай глобальный фрейм <k>NSPanelEventFrame</k>:</t>
<t>- тип: <s>"Frame"</s>;</t>
<t>- глобальное имя: <s>"NSPanelEventFrame"</s>;</t>
<t>- родитель: <k>UIParent</k>;</t>
<t>- зарегистрируй событие <s>"PLAYER_TARGET_CHANGED"</s> через <k>RegisterEvent</k>;</t>
<t>- зарегистрируй событие <s>"PLAYER_REGEN_ENABLED"</s> через <k>RegisterEvent</k>;</t>
<t>- назначь скрипт <k>OnEvent</k>, который вызывает <k>NSPanelUpdate()</k> при любом из этих событий.</t>
<t>Ничего выводить через print не нужно.</t>
]=],
initialCode = [=[
-- Создай NSPanelUpdate и NSPanelEventFrame
]=],
requireKeywords = {
"NSPanelEventFrame",
"NSPanelUpdate",
"CreateFrame",
"Frame",
"RegisterEvent",
"PLAYER_TARGET_CHANGED",
"PLAYER_REGEN_ENABLED",
"SetScript",
"OnEvent",
},
checkCode = function()
_G.checkError = nil
if type(_G.NSPanelUpdate) ~= "function" then
_G.checkError = "NSPanelUpdate должна быть глобальной функцией"
return false
end
local f = _G.NSPanelEventFrame
if not f or type(f.GetScript) ~= "function" then
_G.checkError = "NSPanelEventFrame не является фреймом"
return false
end
local script = f:GetScript("OnEvent")
if type(script) ~= "function" then
_G.checkError = "У фрейма должен быть обработчик OnEvent"
return false
end
-- Проверяем, что обработчик вызывает NSPanelUpdate
local updateCalled = false
local oldUpdate = _G.NSPanelUpdate
_G.NSPanelUpdate = function()
updateCalled = true
end
local ok, err = pcall(script, f, "PLAYER_TARGET_CHANGED")
_G.NSPanelUpdate = oldUpdate
if not ok then
_G.checkError = "Ошибка при вызове OnEvent: " .. tostring(err)
return false
end
if not updateCalled then
_G.checkError = "OnEvent должна вызывать NSPanelUpdate"
return false
end
return true
end,
}

ns_llua['lua'][364] = {
type = "commenttest",
title = "Проект шаг 5: финальная сборка",
helpModules = {359, 53, 83, 137, 215, 227, 233, 239},
preloadVars = {
{var = "NSPanelFrame", desc = "NSPanelFrame очищается перед проверкой"},
{var = "NSPanelTitle", desc = "NSPanelTitle очищается перед проверкой"},
{var = "NSPanelInfo", desc = "NSPanelInfo очищается перед проверкой"},
{var = "NSPanelCoords", desc = "NSPanelCoords очищается перед проверкой"},
{var = "NSPanelButton", desc = "NSPanelButton очищается перед проверкой"},
{var = "NSPanelUpdate", desc = "NSPanelUpdate очищается перед проверкой"},
{var = "NSPanelEventFrame", desc = "NSPanelEventFrame очищается перед проверкой"},
{var = "checkError", desc = "checkError очищается перед проверкой"},
},
reportVars = {
"checkError",
},
instruction = [=[
<h>Проект шаг 5: финальная сборка</h>
<t>Собери весь проект в одном блоке кода. Создай все глобальные переменные:</t>
<t>1. <k>NSPanelFrame</k> — основной фрейм (280x220, CENTER, HIGH, показан).</t>
<t>2. <k>NSPanelTitle</k> — FontString с заголовком <s>"Панель персонажа"</s>.</t>
<t>3. <k>NSPanelInfo</k> — FontString с данными игрока (имя, уровень, HP).</t>
<t>4. <k>NSPanelCoords</k> — FontString с координатами (X и Y в процентах).</t>
<t>5. <k>NSPanelButton</k> — кнопка <s>"Обновить"</s>, вызывает NSPanelUpdate.</t>
<t>6. <k>NSPanelUpdate</k> — функция, которая обновляет NSPanelInfo и NSPanelCoords.</t>
<t>7. <k>NSPanelEventFrame</k> — фрейм с событиями PLAYER_TARGET_CHANGED и PLAYER_REGEN_ENABLED.</t>
<t>Функция <k>NSPanelUpdate</k> должна:</t>
<t>- получить имя, уровень, HP через UnitName, UnitLevel, UnitHealth, UnitHealthMax;</t>
<t>- получить координаты через GetPlayerMapPosition("player");</t>
<t>- обновить текст в NSPanelInfo и NSPanelCoords через SetText.</t>
<t>Вызови <k>NSPanelUpdate()</k> один раз в конце.</t>
<t>Ничего выводить через print не нужно.</t>
]=],
initialCode = [=[
-- Собери весь проект здесь
]=],
requireKeywords = {
"NSPanelFrame",
"NSPanelTitle",
"NSPanelInfo",
"NSPanelCoords",
"NSPanelButton",
"NSPanelUpdate",
"NSPanelEventFrame",
"CreateFrame",
"CreateFontString",
"SetText",
"UnitName",
"UnitHealth",
"GetPlayerMapPosition",
"RegisterEvent",
"SetScript",
"OnClick",
"OnEvent",
},
checkCode = function()
_G.checkError = nil
-- Проверяем фрейм
local f = _G.NSPanelFrame
if not f or type(f.IsShown) ~= "function" then
_G.checkError = "NSPanelFrame не является фреймом"
return false
end
if not f:IsShown() then
_G.checkError = "NSPanelFrame должен быть показан"
return false
end
-- Проверяем заголовок
local title = _G.NSPanelTitle
if not title or type(title.SetText) ~= "function" then
_G.checkError = "NSPanelTitle не является FontString"
return false
end
if title:GetText() ~= "Панель персонажа" then
_G.checkError = "NSPanelTitle должен содержать 'Панель персонажа'"
return false
end
-- Проверяем инфо
local info = _G.NSPanelInfo
if not info or type(info.SetText) ~= "function" then
_G.checkError = "NSPanelInfo не является FontString"
return false
end
-- Проверяем координаты
local coords = _G.NSPanelCoords
if not coords or type(coords.SetText) ~= "function" then
_G.checkError = "NSPanelCoords не является FontString"
return false
end
-- Проверяем функцию обновления
if type(_G.NSPanelUpdate) ~= "function" then
_G.checkError = "NSPanelUpdate должна быть глобальной функцией"
return false
end
local ok1, err1 = pcall(_G.NSPanelUpdate)
if not ok1 then
_G.checkError = "Ошибка вызова NSPanelUpdate: " .. tostring(err1)
return false
end
local infoText = info:GetText()
if type(infoText) ~= "string" or infoText == "" then
_G.checkError = "NSPanelInfo должен содержать текст"
return false
end
local playerName = UnitName("player")
if playerName and not infoText:find(playerName, 1, true) then
_G.checkError = "NSPanelInfo должен содержать имя игрока"
return false
end
local coordsText = coords:GetText()
if type(coordsText) ~= "string" or coordsText == "" then
_G.checkError = "NSPanelCoords должен содержать текст"
return false
end
-- Проверяем кнопку
local btn = _G.NSPanelButton
if not btn or type(btn.GetScript) ~= "function" then
_G.checkError = "NSPanelButton не является кнопкой"
return false
end
local onClick = btn:GetScript("OnClick")
if type(onClick) ~= "function" then
_G.checkError = "У кнопки должен быть обработчик OnClick"
return false
end
-- Проверяем, что OnClick вызывает NSPanelUpdate
local updateCalled = false
local oldUpdate = _G.NSPanelUpdate
_G.NSPanelUpdate = function()
updateCalled = true
end
pcall(onClick, btn, "LeftButton")
_G.NSPanelUpdate = oldUpdate
if not updateCalled then
_G.checkError = "OnClick должна вызывать NSPanelUpdate"
return false
end
-- Проверяем фрейм событий
local ef = _G.NSPanelEventFrame
if not ef or type(ef.GetScript) ~= "function" then
_G.checkError = "NSPanelEventFrame не является фреймом"
return false
end
local onEvent = ef:GetScript("OnEvent")
if type(onEvent) ~= "function" then
_G.checkError = "У NSPanelEventFrame должен быть обработчик OnEvent"
return false
end
-- Проверяем, что OnEvent вызывает NSPanelUpdate
updateCalled = false
_G.NSPanelUpdate = function()
updateCalled = true
end
pcall(onEvent, ef, "PLAYER_TARGET_CHANGED")
_G.NSPanelUpdate = oldUpdate
if not updateCalled then
_G.checkError = "OnEvent должна вызывать NSPanelUpdate"
return false
end
return true
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
    self.moduleText:SetText(string.format(
        "Модуль %s из %s",
        tostring(index or "?"),
        tostring(total or "?")
    ))
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

local function CompareModuleIds(a, b)
    local sa = tostring(a)
    local sb = tostring(b)

    local pa = {}
    for part in sa:gmatch("[^.]+") do
        table.insert(pa, part)
    end

    local pb = {}
    for part in sb:gmatch("[^.]+") do
        table.insert(pb, part)
    end

    local maxLen = math.max(#pa, #pb)

    for i = 1, maxLen do
        local va = pa[i]
        local vb = pb[i]

        -- Более короткий номер считается раньше:
        -- 3 раньше, чем 3.1
        if va == nil then
            return true
        end

        if vb == nil then
            return false
        end

        local na = tonumber(va)
        local nb = tonumber(vb)

        if na and nb then
            if na ~= nb then
                return na < nb
            end
        else
            if va ~= vb then
                return va < vb
            end
        end
    end

    return sa < sb
end

local Logic = {}
Logic.__index = Logic

function Logic:BuildOrder()
    local order = {}

    for id, module in pairs(self.db or {}) do
        if type(id) == "number" and type(module) == "table" then
            table.insert(order, id)
        end
    end

    table.sort(order, CompareModuleIds)

    self.order = order
    self.total = #order
    self.orderIndex = {}

    for i, id in ipairs(order) do
        self.orderIndex[id] = i
    end
end

function Logic:FindModuleIndex(moduleId)
    local id = tonumber(moduleId)

    if id == nil then
        return nil
    end

    if self.orderIndex and self.orderIndex[id] then
        return self.orderIndex[id]
    end

    return nil
end

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

    self.order = {}
    self.orderIndex = {}

    self:BuildOrder()

    self.current = self.order[1] or 1
    self.currentIndex = self.orderIndex[self.current] or 1
    self.total = self.total or 0

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
    self:BuildOrder()

    if self.total == 0 then
        return
    end

    self:EnsureSaved()

    if signal == "next" or signal == "prev" then
        local idx = self:FindModuleIndex(nsDbc.luaTest.currentModule)
            or self:FindModuleIndex(self.current)

        if idx then
            if signal == "next" then
                idx = idx + 1

                if idx > self.total then
                    idx = self.total
                end
            else
                idx = idx - 1

                if idx < 1 then
                    idx = 1
                end
            end
        else
            idx = 1
        end

        self.current = self.order[idx]
    else
        local desired = tonumber(signal)

        if desired == nil then
            desired = tonumber(nsDbc.luaTest.currentModule)
        end

        local idx = self:FindModuleIndex(desired)

        if not idx then
            idx = 1
        end

        self.current = self.order[idx]
    end

    self.currentIndex = self:FindModuleIndex(self.current) or 1
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
    local m = self.db and self.db[n]

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

    local currentIndex = self.currentIndex or 1

    if self.FindModuleIndex then
        currentIndex = self:FindModuleIndex(n) or currentIndex
    end

    local data = {
        title = m.title or "",
        index = n,
        total = self.total or 0,
        prevEnabled = currentIndex > 1,
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