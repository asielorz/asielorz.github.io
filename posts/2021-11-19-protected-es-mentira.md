---
layout: post
title: protected es mentira
date: 2021-11-19
tags:
  informática
  programación
---
> "I work with very good programmers and I see a ton of happens-to-work and very little actually correct."
> 
> -Titus Winters

Es común, en lenguajes de programación que permiten programar en un estilo orientado a objetos, que se pueda restringir el acceso a los miembros de una clase. Los especificadores de acceso más comunes suelen ser `public`, que permite que el miembro sea accedido desde cualquier lugar; `private`, que sólo permite que el miembro sea accedido por funciones miembro de la clase, y `protected`, que permite que el miembro sea accedido por las funciones de esta clase y aquellas que deriven de esta clase, transitivamente. Estos tres especificadores de acceso suelen ser los más comunes y los encontramos en lenguajes como C++, Java o C#. Mientras que `public` y `private` tienen significados sólidos, bien definidos y correctamente ejecutados por el lenguaje de programación, el significado de `protected` es más pobre, hasta el punto de que podríamos considerarlo equivalente a `public`.

## Cómo saltarse `protected`, el tutorial

Supongamos que hay una clase que tiene un miembro `protected` al que necesitamos acceder. Por ejemplo, el estándar manda que `std::stack` tenga su contenedor interno en una variable miembro `protected` llamada `c`. Ahora, supongamos que tenemos una stack que contiene un vector, y en la que queremos hacer que el vector reserve cierta cantidad de elementos de antemano para evitar crecer el bloque mientras se usa la stack. En principio, acceder al vector interno desde fuera es imposible, ya que éste es `protected`. Sin embargo, nada nos impide escribir algo así:

```cpp
template <typename T, typename C>
auto underlying_container(std::stack<T, C> & stack) -> C &
{
    struct Oops : public std::stack<T, C>
    {
        auto get_underlying_container() -> C & { return c; }
    };
    return static_cast<Oops &>(stack).get_underlying_container();
}
```

Veamos un poco qué está sucediendo en esta función. Se está declarando, dentro de la función, una nueva clase que deriva de aquella en la que se quiere acceder a un miembro protegido y añade una función que permite acceder a ese miembro. Como la función `get_underlying_container` es un miembro de una clase que hereda de `std::stack`, tiene permitido acceder a `c`. Es importante tener en cuenta también que este código no es peligroso ni puede incurrir en undefined behavior accidentalmente ni va a dejar de funcionar misteriosamente en el futuro. No se está quitando `const` a nada, ni reinterpretando pointers como tipos no relacionados. `std::stack` y el tipo al que hemos decidido bautizar como `Oops` tienen exactamente la misma disposición en binario, ya que `Oops` no añade ninguna variable, lo que significa que acceder a `c` desde `std::stack` y desde `Oops` es exactamente la misma operación. Otra ventaja de esta técnica es que la existencia de `Oops` es local a la función `underlying_container`. No necesitamos cambiar todos los sitios en los que usamos `std::stack` por un `Oops`. Podemos seguir usando `std::stack` y aun así acceder a sus miembros protegidos con funciones como ésta.

Además, es importante tener en cuenta que esto no es una particularidad de `std::stack`. Puede usarse esta técnica para acceder a cualquier variable protegida de cualquier clase de forma segura y no intrusiva. Una vez llegado a este punto, cualquier variable protegida es en realidad pública en la práctica, sólo que con un poco de tedio extra. Una vez que tenemos `underlying_container`, podemos hacer algo como:

```cpp
std::stack<int, std::vector<int>> stack;
underlying_container(stack).reserve(64);
```

## De todas formas, ¿qué significa `protected`?

Antes hemos mencionado que los significados de `public` y `private` están bien definidos. Para variables, una variable pública es una variable que no tiene precondiciones, o, dicho de otra forma, que no participa en las invariantes de la clase. Es seguro hacer cualquier operación segura sobre una variable pública sin invalidar el estado de la clase en la que vive. Por el contrario, una variable privada es una variable cuyo valor está restringido por las invariantes de la clase. Por ejemplo, una clase de vector suele contener tres variables: el pointer a la memoria, el tamaño y la capacidad. Sin embargo, estas tres variables no tienen valores arbitrarios y no relacionados entre sí. El pointer apunta a un array que tiene memoria como para tantos elementos como capacidad tenga el vector y en el que hay tantos elementos construidos como tamaño tenga el vector. El valor de las tres variables está estrechamente relacionado, y modificar cualquiera de ellas al azar, sin valorar su significado y cómo afecta al resto, es un error. Por eso, estas variables son privadas, para que sólo puedan ser manipuladas por un puñado de operaciones que sabemos que son seguras y no van a invalidar el estado de la clase.

Para funciones, el significado es parecido. Una función pública suele representar una operación segura. Una operación que puede invocarse en una clase cuyas invariantes estén satisfechas y que garantiza que al terminar las invariantes de la clase seguirán cumpliéndose. Por el contrario, una función privada suele ser un detalle de implementación de las funciones públicas y suele tener permitido operar sobre estados inválidos de la clase ya que nunca va a ser llamada fuera de contexto. Siempre se va a llamar desde otra función miembro de la clase que entiende su significado y se va a encargar de que al final el estado de la clase vuelva a ser válido.

Pero, ¿qué es un miembro protegido? Por un lado, que el acceso a un miembro protegido pudiera poner en peligro las invariantes de la clase sería algo inseguro, ya que puede ser accedido por código de terceros. Recordemos que, a menos que la clase sea final (en cuyo caso `protected` significa exactamente lo mismo que `private`), cualquiera puede extender una clase y acceder a un miembro protegido, por lo que debería ser tratado por el implementador de la clase, a efectos prácticos, como si fuera un miembro público más de la clase. Un miembro protegido es parte de la interfaz de la clase con la que va a interactúar código de terceros, por lo que a menos que queramos cargar sobre éstos el peso de entender y mantener las invariantes de una clase que no han escrito, un miembro protegido tiene que tener las mismas garantías de seguridad que uno público. Por otro lado, si es un miembro en el que es seguro operar y sobre el que no pesa ninguna invariante de clase, ¿por qué no es público? ¿Por qué hacer que el acceso sea tan incómodo y tedioso?

## Conclusión

Un miembro protegido es, a efectos prácticos, público, ya que puede ser accedido libremente por código de terceros. Por lo tanto, a la hora de diseñar una clase, y decidir el especificador de acceso de un miembro, un miembro protegido debería tener las mismas garantías de seguridad que uno público. Y, una vez llegado a este punto, si operar sobre él es seguro, cabría preguntarse por qué es ese miembro protegido y no público. Ver un `protected` en el código suele ser señal de que una clase ha tenido poca reflexión sobre cuál es su interfaz y cómo debería ser usada, y en general está cerca de ser un antipatrón a evitar en la medida de lo posible. En el mejor de los casos, un miembro protegido es un miembro público pero con restricciones artificiales para que acceder a él sea más tedioso de lo que debería. En el peor de los casos, es un bug latente esperando a saltar por los aires.
