---
layout: post
title: Programación procedural, orientación a objetos y dónde se pone la frontera de la interfaz
date: 2021-12-14
tags:
  informática
  programación
---
La definición que da Alan Kay de la orientación a objetos es muy bonita. Kay define la orientación a objetos como la recursión del concepto de ordenador. El diseñar los componentes de un programa como entes independientes con su propio estado y capacidad de computación que se comunican mediante mensajes, al igual que lo hacen varios ordenadores conectados en una red. Para Kay, la orientación a objetos consistiría en coger esta idea de los ordenadores conectados en una red y aplicarla recursivamente, implementando cada uno de los programas que esos ordenadores están ejecutando en términos de pequeños “ordenadores” independientes, llamados objetos, que se comunican mediante mensajes y donde cada uno de ellos está asimismo compuesto por una red de objetos más pequeños, hasta llegar a los primitivos del lenguaje. Creo que es importante recordar la filosofía de Kay sobre todo para aquellos para los que nuestra percepción de la orientación a objetos viene modulada por lenguajes como C++, Java o C#. Las funciones virtuales y los patrones de diseño de la gang of four son circunstanciales, la encapsulación y la comunicación mediante mensajes son la esencia. Según estos criterios, el modelo de actores de Erlang podría considerarse más orientado a objetos que mucho código escrito en Java. Como dijo el propio el propio Alan Kay, “cuando acuñé el término orientado a objetos no estaba pensando en C++”.

Los lenguajes procedurales, especialmente aquellos que no tienen una forma de automatizar la gestión de recursos, tienden a buscar una forma estructurada de organizar la memoria de los programas para facilitar operaciones como liberar recursos o detectar fugas. Una de las técnicas más eficaces para lograr esto es mover toda la gestión de memoria a “sistemas” centralizados que son los propietarios únicos de su memoria. Estos sistemas agrupan los datos en arrays cuya memoria es privada al sistema, y al crear objetos nuevos únicamente devuelven un índice que identifica al elemento creado y permite operar en él a través de las operaciones del sistema. Podemos ver este diseño aplicado paso por paso en la interfaz de OpenGL, por ejemplo.

Lo llamativo de esta idea es que estos “sistemas” se parecen mucho a los “objetos” de la programación orientada a objetos. Su estado es privado, ofrecen al exterior una interfaz compuesta por la serie de mensajes que aceptan y la información que devuelven a esos mensajes, y sobre todo se definen por el servicio que prestan o las operaciones que llevan a cabo, no por su valor (es decir, no son tipos de dato abstractos). La diferencia principal parece radicar, no tanto en los principios de diseño sino en dónde se pone la frontera de la interfaz.

Mientras que la orientación a objetos defiende que cada componente de un programa tiene que ser un objeto, y que los objetos grandes se componen de objetos autónomos más pequeños, la programación procedural limita la interfaz orientada a objetos de Kay a los sistemas, mientras que en un sistema de puertas para adentro todo es público y está escrito en un estilo procedural, y con esto intenta conseguir lo mejor de los dos mundos. Por un lado, se tiene una interfaz segura que es difícil de usar mal y que expone lo mínimo posible de la implementación del sistema, de forma que sea fácil hacer cambios en la implementación sin romper a los usuarios. Por otro lado, se tiene un control total sobre la implementación del sistema, sus estructuras de datos y algoritmos, sin estar limitado por lo que otros objetos deciden ofrecer en su interfaz o esconder en su implementación. Esto facilita escribir un código eficiente para la implementación de los sistemas.

Contrariamente a lo que uno intuiría, dentro de la programación procedural haya lugar para las ideas de Alan Kay, y la diferencia entre ambos paradigmas no es tanto de raíz como un debate sobre dónde poner la frontera de la interfaz de mensajes que encapsulan el estado. Mientras que la orientación a objetos propone crear muchas fronteras pequeñas que se componen recursivamente, centrándose sobre todo en asegurarse de evitar estados incorrectos maximizando la encapsulación, la programación procedural decide crear pocas fronteras grandes que permiten a partes del programa desarrollarse independientemente mientras que cada sistema internamente mantiene un alto grado de libertad de implementación y de oportunidad para la optimización. Pero lo que no está en discusión en ninguno de los paradigmas es que es beneficioso para poder escalar el tamaño de los programas que en algún momento se limite la comunicación entre partes del programa mediante interfaces de mensajes como las descritas por Alan Kay.