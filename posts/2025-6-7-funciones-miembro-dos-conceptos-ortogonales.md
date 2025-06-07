---
title: Las funciones miembro atan dos conceptos ortogonales
date: 2025-6-7
image: /images/pizza.png
image-alt: Fotografía de tres pizzas sobre una mesa de madera. La más cercana está sobre un plato metálico, las otras dos sobre soportes metálicos con patas, lo que crea una composición triangular con las pizzas a tres alturas distintas. En el fondo se vislumbra la luz de un horno de leña, pero está muy desenfocada.
image-credit: "Fotografía de stock de Narda Yescas ([fuente](https://www.pexels.com/es-es/foto/fotografia-de-enfoque-superficial-de-varias-pizzas-1566837/))"
tags:
  informática
  programación
---
Hace mucho tiempo que no me gusta la sintaxis de función miembro, pero hasta ahora no tenía una articulación coherente del porqué. Viendo el último episodio de _Software Unscripted_, en el que Richard Feldman y José Valim hablan sobre el tema cuando Feldman explica que Roc ha añadido esta sintaxis, por fin he llegado a una teoría completa de qué es lo que me disgusta.

Por dejar claro de qué estamos hablando, me refiero a llamar a funciones con la sintaxis `primer_parámetro.función(los, otros, parámetros)`. Esta forma de llamar a funciones es extremadamente común en la mayoría de lenguajes populares y la encontramos en C++, Java, C#, Python, JavaScript, Swift y Rust entre muchos otros. Los lenguajes en los que no encontramos esta sintaxis son, o bien lenguajes imperativos de la vieja escuela como C, o en lenguajes funcionales herederos de ML o Lisp.

# Lo bueno

Una de las principales ventajas de esta sintaxis, que no se puede desdeñar, es que es conocida y esperada por un amplio porcentaje de los programadores y no tenerla puede hacer que la experiencia de usar el lenguaje resulte más incómoda y más difícil de aprender, sobre todo al principio. También es mejor de cara al autocompletado en el editor, ya que al escribir el punto después del primer parámetro el editor muestra una selección de funciones que se pueden usar. Esto es de gran ayuda, sobre todo (pero no exclusivamente) para principiantes. Hay quien dice también que esta forma de escribir llamadas a funciones es más natural de leer para hablantes de muchos idiomas al tener una estructura de sujeto-verbo-predicado en ese orden.

Otra de las ventajas es la posibilidad de encadenar varias llamadas a funciones escribiendo esas funciones en el orden en el que se ejecutan. Con la sintaxis de función convencional, si escribimos `h(g(f(x)))`, esto significa que primero se ejecutará `f`, luego `g` y por último `h`, en el orden inverso al escrito en el código. La sintaxis de función miembro nos permite escribir la misma expresión como `x.f().g().h()`, lo que nos permite leer el código en el orden en el que se ejecuta. Esto es más legible para algunas personas y algunos casos.

La última ventaja es el no tener que escribir la cualificación completa de cada función para llamarla. Esto es visible en Rust, donde todas las funciones miembro pueden llamarse también como funciones libres. Así, dadas dos strings `s` y `filter`, la expresión `s.to_lowercase().contains(&filter)` puede escribirse como `str::contains(&str::to_lowercase(&s), &filter)`, que es más largo y feo.

# Lo malo

El principal problema de las funciones miembro es que crea una segregación artificial entre funciones que se llaman de una forma y funciones que se llaman de otra. Algunas funciones, porque están escritas de una forma concreta, se llaman con la sintaxis de función miembro. El resto se llaman con la sintaxis convencional de función libre. La distinción es arbitraria y a menudo no significa diferencias de comportamiento, sino simplemente altera la forma del código.

Esta sintaxis también es limitada en el hecho de que la mayoría de lenguajes restringen en gran medida el tipo del primer parámetro. En C# y Java tiene que ser una referencia mutable al objeto. En C++ hay más flexibilidad, permitiendo elegir la mutabilidad y volatilidad de la referencia, así como si es una referencia a lvalue o rvalue. La reciente propuesta de deducing this, aceptada en C++23, permite también por fin pasar this por copia. Rust sería el lenguaje que ofrece mayor flexibilidad en este aspecto, permitiendo que self, además de ser una copia o una referencia, mutable o inmutable, pueda ser también Pin, Box, Rc o Arc. De todas formas, esto sigue siendo más limitado de lo que ofrecen las funciones normales, donde el primer parámetro podría ser una lista, un option o un tipo genérico, entre otros ejemplos. En la mayoría de lenguajes de programación, pensar en funciones miembro restringe la imaginación del programador a funciones concretas sobre un solo objeto de un tipo.

El conjunto de funciones privilegiadas que pueden llamarse con la sintaxis de miembro también tiende también a ser cerrado. En lenguajes orientados a objetos se suele limitar a las funciones definidas dentro de la clase del primer parámetro. En Rust solamente podemos llamar de esta manera a funciones declaradas en bloques `impl` del tipo del primer parámetro, que sólo pueden escribirse en el mismo módulo que ese tipo. El principal inconveniente de esta limitación es que, al escribir expresiones que encadenan varias llamadas a funciones como en el ejemplo `x.f().g().h()` anterior, sólo se pueden usar funciones declaradas como miembro. Además, si se está trabajando sobre tipos definidos por una tercera parte, este conjunto de funciones no es extensible.

En el episodio del podcast, Valim menciona que esta imposibilidad de extender crea una dinámica indeseable en el ecosistema del lenguaje que impulsa a querer añadir más y más funciones a tipos básicos del vocabulario como `String` para poder usarlas con la sintaxis preferible de función miembro.

# Extensiones y unicornios

Diferentes lenguajes han explorado formas de hacer que este conjunto privilegiado de funciones se pueda extender desde fuera del módulo que declara el tipo del primer parámetro. C# tiene bloques de extensión que permiten añadir funciones miembro a otros tipos libremente. En Rust se usa con cierta frecuencia un patrón en el que se declara un nuevo trait que no está pensado para ser implementado por nadie excepto por el tipo que se quiere extender. Esta técnica, que personalmente me parece un apaño bastante chapucero, se usa en crates populares como itertools o futures.

C++ ha arrastrado durante años la discusión de lo que llaman sintaxis uniforme de llamada (uniform call syntax), que permitiría llamas a cualquier función libre como función miembro y viceversa. Esto plantea suficientes dificultades a la hora de resolver a qué función hace referencia un nombre que el asunto lleva años siendo pospuesto ad infinitum sin una resolución clara en el horizonte.

En lenguajes muy dinámicos como Python o Javascript es posible añadir nuevas funciones a un objeto después de haber sido creado con la sintaxis convencional de asignar un miembro. Esto está generalmente considerado como una mala práctica, pero se puede hacer.

# La gran revelación

El problema fundamental de la sintaxis de función miembro es que une en una sola cosa dos conceptos ortogonales. Por un lado, tenemos la posibilidad de escribir el nombre de la función después del primer parámetro, lo que crea expresiones con forma sujeto-verbo-predicado que pueden ser encadenadas fácilmente. Por otro, tenemos la posibilidad de llamar a funciones sin escribir su nombre completamente cualificado, escribiendo únicamente el nombre de la función y dejando que el compilador deduzca a qué nos estamos refiriendo, con reglas de deducción lo bastante sencillas como para no llevarnos sorpresas.

Estas dos ideas no están necesariamente relacionadas la una con la otra. En un lenguaje hipotético podríamos tener llamadas de función en las que el primer parámetro va antes que la función, pero en las que el nombre de la función está completamente cualificado. También podríamos imaginar la sintaxis convencional de llamada de función sin cualificar del todo el nombre de la función, dejando que el compilador de alguna forma deduzca qué está siendo llamado.

El error está en atar estas dos ideas de manera inevitable. Esta unión es el origen de la mayoría de inconvenientes de esta sintaxis y por lo tanto desligar estos dos conceptos lleva a que esos problemas se resuelvan por sí solos, sin tener que hacer malabares y complicar el lenguaje para acomodar más casos.

# Pizza Margherita al forno di pietra

En algunos lenguajes de programación, sobre todo en la tradición funcional de ML, encontramos el operador `|>`, conocido popularmente como operador tubería por la forma en la que permite que los parámetros fluyan de una función a otra u operador pizza por la forma triangular que tiene, parecida a un trozo de pizza.  El operador pizza es muy sencillo. Si de normal escribiríamos llamar a una función f con los parámetros a, b y c como `f a b c`, también podemos escribirlo como `c |> f a b`. El operador simplemente reescribe la expresión para que c sea el último parámetro de la llamada a la función. Que el parámetro que va antes de la pizza se convierta en el último es una convención de los lenguajes funcionales con aplicación parcial, pero nada impediría a un lenguaje decidir que el operador pizza pone el parámetro antes de la pizza en primer lugar. De hecho, esto es lo que hacía el operador pizza en Roc en el pasado.

Este operador resuelve el problema de encadenar funciones de forma que se lean en el orden en el que se van a ejecutar. De hecho, en lenguajes funcionales con operador pizza es muy común ver algoritmos escritos como una sola expresión que encadena llamadas a múltiples funciones.

Aquí un ejemplo aleatorio sacado de una de mis páginas web, escrita en Elm:

```elm
cards
  |> List.filter (card_passes_predicates predicates)
  |> List.Extra.uniqueBy Card.duplicate_id
  |> List.sortWith order
  |> Ok
```

Lo interesante de ejemplo es que estamos usando funciones que provienen de tres módulos distintos. `List.filter` y `List.sortWith` son funciones del módulo de la lista. Podríamos pensar en ellas como funciones miembro de toda la vida. Ahora bien, `List.Extra.uniqueBy` viene del módulo List.Extra, que es un módulo externo descargable que no está vinculado al tipo `List`. En un lenguaje con sintaxis de función miembro no podríamos llamar a esta función así, o tendría que hacer trucos como itertools en Rust. Por último, `Ok` es uno de los constructores de `Result`. Ni siquiera está asociado al tipo List. Es un tipo distinto y viene de un módulo distinto.

El operador pizza resuelve completamente el problema de la extensibilidad. Todas las funciones son libres y se pueden llamar como funciones libres, en el orden de primero la función y luego los parámetros, con la sintaxis tradicional. Además, todas las funciones se pueden llamar en la forma postfijo, primero un parámetro, luego la función, luego el resto de parámetros, usando el operador pizza. No hay funciones privilegiadas con acceso a una sintaxis especial ni asociaciones especiales entre algunos tipos y algunas funciones. Todo funciona con todo siempre.

También resuelve el problema de la falta de expresividad. Al ser funciones libres y reglas de reescritura, el primer (o último) parámetro puede tener el tipo que queramos. Puede ser genérico, puede ser una lista o un valor opcional o un parser de JSON, da igual. Las limitaciones artificiales de qué cualifica como un tipo `this` o `self` legal no tienen sentido en este caso. De nuevo, todo funciona con todo siempre, sin casos raros.

Tampoco hay ambigüedad sobre qué función se llamará. Al tener que cualificar las funciones, esa información está ahí mismo, en el código. No hay reglas abstrusas de resolución de overloads de funciones ni posibilidad de rupturas inesperadas de la retrocompatibilidad.

# Tenemos `using` en casa

La mayoría de lenguajes de programación también ofrecen una forma de referirse a una entidad por nombre sin tener que cualificar el nombre por completo.

En C++ podemos hacer `using namespace` para traer todos los nombres de un namespace al scope actual. También podemos hacer `using` a secas para traer solamente nombres concretos. En C# también podemos usar `using` para hacer que todos los nombres de un namespace sean usables en el scope actual.

Python tiene la sintaxis `from X import Y` para importar el objeto Y del módulo X al archivo actual sin tener que cualificar el nombre.

Rust tiene una rica sintaxis para su declaración `use` que permite importar tanto nombres concretos como módulos enteros.

En Elm, al importar un módulo, podemos usar la palabra clave `exposing` al importar un módulo para que algunos nombres concretos del módulo (o todos si se hace `exposing (..)`) sean usables directamente en el archivo actual.

El caso es que la mayoría de lenguajes que existen tienen un sistema para exponer nombres de otros módulos a otra parte del programa de manera (más o menos) limpia, que se puede usar ortogonalmente con el resto del lenguaje. Los que no lo tienen, como C, es a menudo porque ni siquiera tienen un sistema de módulos o espacios de nombres propiamente dicho.

No hay ninguna necesidad de atar la resolución de nombres no cualificados a la sintaxis de llamada de función. Hacer eso complica el diseño del lenguaje de manera innecesaria y cierra puertas o pone palos en las ruedas a la hora de diseñar otras partes del lenguaje.

# Conclusiones

Las funciones miembro son mayormente una mala idea. Con la perspectiva de 40 años de lenguajes que las usan, así como de alternativas que funcionan, podemos decir que los inconvenientes que aportan son evitables porque podemos lograr los mismos objetivos mediante otros medios, separando las dos cosas que se logran mediante las funciones miembro en dos elementos independientes y ortogonales: el operador pizza y la declaración `using` (o `use` o `import` o `exposing` o tu palabra clave favorita).

Los únicos puntos a favor no reemplazables de las funciones miembro son la familiaridad de los programadores que ya saben usar otros lenguajes de programación y esperan encontrar algo así por costumbre y la integración de esta forma de programar en editores de texto diseñados para optimizar este caso.

La decisión de Roc de adoptar esta sintaxis en lugar de favorecer el operador pizza me parece personalmente una regresión en el diseño.
