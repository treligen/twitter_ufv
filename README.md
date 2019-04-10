# Text mining para tweets de fútbol

Este repositorio contiene los códigos necesarios para el **taller de text mining** impartido el 10 de abril en la Universidad Francisco de Vitoria.

El taller está dedicado a:

1. Cómo **extraer tweets** desde R a través de la API de Twitter. La extracción se hace sobre partidos de Liga.
2. **Transformaciones** necesarias para el tratamiento adecuado de los tweets.
3. Estudiar la tendencia del **número de tweets escritos en cada minuto**.
4. **Nube de pabalabras** *(wordcloud)* sobre los insultos contenidos en los tweets.
5. **Geolocalización** de los tweets.

## Estructura de carpetas

El repositorio está estructurado como:

- `src/`: contiene los códigos escritos en R.
    `src/taller`: códigos específicos para seguir el taller. Estos códigos están comentados con un nivel de detalle muy alto para facilitar su comprensión.
- `data/`: se almacenan la extracción de los tweets. Además, hay un archivo `insultos_utf8.txt` con un diccionario de insultos.

