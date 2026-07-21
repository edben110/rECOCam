# rECOCam

**Aplicación de clasificación de residuos reciclables con inteligencia artificial local**

rECOCam es una aplicación móvil desarrollada en Flutter que utiliza TensorFlow Lite con MobileNetV3 Large para identificar objetos reciclables, determinar su material, y proporcionar recomendaciones de disposición final según la normativa colombiana de separación de residuos.

Toda la inferencia se ejecuta **completamente en el dispositivo** — sin servicios en la nube ni conexiones a internet.

---

## Características

- Captura de fotos con la cámara del dispositivo
- Selección de imágenes desde la galería
- Clasificación de objetos usando MobileNetV3 Large (TensorFlow Lite)
- Identificación del material predominante
- Porcentaje de confianza de la IA
- Estado de reciclabilidad y reutilización
- Color del contenedor recomendado (normativa colombiana)
- Recomendaciones de disposición final
- Arquitectura modular y escalable
- 31 objetos en la base de conocimiento local

---

## Arquitectura

```
lib/
├── core/                          # Capa core (compartida)
│   ├── config/
│   │   └── app_config.dart        # Configuración centralizada
│   ├── constants/
│   │   └── app_constants.dart     # Constantes y valores por defecto
│   ├── exceptions/
│   │   └── app_exceptions.dart    # Excepciones personalizadas
│   ├── utils/
│   │   ├── image_utils.dart       # Utilidades de imagen
│   │   └── format_utils.dart      # Utilidades de formato
│   └── services/
│       ├── camera_service.dart    # Servicio de cámara
│       ├── image_classifier.dart  # Clasificador TFLite
│       └── logger_service.dart    # Servicio de logging
│
├── domain/                        # Capa de dominio
│   ├── entities/
│   │   ├── recycle_result.dart    # Entidad resultado
│   │   └── recycle_knowledge.dart # Entidad conocimiento
│   ├── repositories/
│   │   └── recycle_repository.dart # Interfaz del repositorio
│   └── usecases/
│       └── analyze_image_usecase.dart # Caso de uso
│
├── data/                          # Capa de datos
│   ├── datasources/
│   │   └── recycle_knowledge_datasource.dart # Fuente JSON
│   ├── models/
│   │   └── recycle_rule_model.dart # Modelo de datos
│   └── repositories/
│       └── recycle_repository_impl.dart # Implementación
│
├── presentation/                  # Capa de presentación (MVVM)
│   ├── pages/
│   │   ├── home/
│   │   │   └── home_page.dart     # Pantalla principal
│   │   └── result/
│   │       └── result_page.dart   # Pantalla de resultado
│   ├── widgets/
│   │   ├── camera_preview_widget.dart   # Vista previa cámara
│   │   ├── analysis_result_widget.dart  # Resultados análisis
│   │   └── error_display_widget.dart    # Mensajes de error
│   ├── viewmodels/
│   │   └── recycle_viewmodel.dart  # ViewModel principal
│   └── routes/
│       └── app_router.dart        # Enrutamiento
│
└── main.dart                      # Punto de entrada
```

### Patrones aplicados

| Patrón | Uso |
|--------|-----|
| **Clean Architecture** | Separación en domain, data, presentation |
| **MVVM** | ViewModel con ChangeNotifier en la capa de presentación |
| **Repository Pattern** | Interfaz en domain, implementación en data |
| **Dependency Injection** | Provider para inyección de dependencias |
| **Singleton** | CameraService, LoggerService |
| **Strategy** | Búsqueda flexible en base de conocimiento |
| **SOLID** | Aplicado en todas las capas |

### Principios aplicados

- **SRP**: Cada clase tiene una única responsabilidad
- **OCP**: La base de conocimiento es ampliable sin modificar código
- **LSP**: Las excepciones personalizadas extienden AppException
- **ISP**: Interfaz de repositorio mínima y específica
- **DIP**: La capa de dominio no depende de implementaciones concretas

---

## Dependencias

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `camera` | ^0.11.0 | Control de cámara |
| `image_picker` | ^1.1.2 | Selección de galería |
| `tflite_flutter` | ^0.11.0 | Inferencia TensorFlow Lite |
| `provider` | ^6.1.2 | Inyección de dependencias y estado |
| `path_provider` | ^2.1.5 | Rutas del sistema de archivos |
| `path` | ^1.9.1 | Manipulación de rutas |
| `permission_handler` | ^11.4.0 | Gestión de permisos |
| `equatable` | ^2.0.7 | Comparación de entidades |
| `collection` | ^1.19.1 | Utilidades de colecciones |
| `intl` | ^0.19.0 | Formato internacionalizado |
| `uuid` | ^4.5.1 | Generación de IDs únicos |
| `logger` | ^2.5.0 | Sistema de logging |
| `shared_preferences` | ^2.3.4 | Persistencia ligera |
| `image` | ^4.5.2 | Manipulación de imágenes |

---

## Requisitos previos

- Flutter SDK 3.44.6 o superior
- Dart SDK 3.12.2 o superior
- Android Studio / VS Code con plugins de Flutter
- Dispositivo Android (API 21+) o iOS (12.0+)
- Modelo MobileNetV3 Large cuantizado INT8

---

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/recocam.git
cd recocam
```

### 2. Descargar el modelo TFLite

Descarga el modelo **MobileNetV3 Large cuantizado INT8** en formato TensorFlow Lite.

**Opción A: Desde TensorFlow Hub**

```bash
# Descargar el modelo (reemplaza la URL con la versión actual)
wget -O assets/models/mobilenet_v3_large.tflite \
  "https://tfhub.dev/google/lite-model/imagenet/mobilenet_v3_large_224/1/classification/1?lite-format=tflite"
```

**Opción B: Desde el repositorio de TensorFlow Models**

```bash
# Usando el conversor de TensorFlow
pip install tensorflow
python -c "
import tensorflow as tf
converter = tf.lite.TFLiteConverter.from_saved_model('mobilenet_v3_large')
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.int8]
tflite_model = converter.convert()
with open('assets/models/mobilenet_v3_large.tflite', 'wb') as f:
    f.write(tflite_model)
"
```

**Opción C: Modelo pre-entrenado de TF Hub (recomendado)**

Visita [tfhub.dev](https://tfhub.dev) y busca "MobileNetV3 Large 224" en formato TFLite. Descarga el archivo `.tflite` y colócalo en `assets/models/`.

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Ejecutar

```bash
# Android
flutter run

# iOS
cd ios && pod install && cd ..
flutter run
```

---

## Ejecución

```bash
# Modo desarrollo
flutter run

# Build de release Android
flutter build apk --release

# Build de release iOS
flutter build ios --release
```

---

## Cómo actualizar el modelo

1. Descarga el nuevo modelo `.tflite`
2. Reemplaza el archivo en `assets/models/mobilenet_v3_large.tflite`
3. Actualiza `assets/labels/labels.txt` si las etiquetas cambiaron
4. Actualiza `assets/json/recycle_rules.json` si hay nuevos objetos
5. Ejecuta `flutter clean && flutter pub get && flutter run`

---

## Cómo cambiar labels

Edita el archivo `assets/labels/labels.txt` con una etiqueta por línea:

```
plastic bottle
glass bottle
can
...
```

**Importante:** Las etiquetas deben coincidir exactamente con las del modelo entrenado. Si el modelo usa etiquetas del dataset ImageNet, necesitarás mapearlas en la base de conocimiento JSON.

---

## Cómo agregar nuevos materiales

Edita `assets/json/recycle_rules.json` y agrega una nueva entrada:

```json
{
  "label": "etiqueta_del_modelo",
  "material": "Nombre del Material",
  "recyclable": true,
  "reusable": false,
  "container_color": "Amarillo",
  "description": "Descripción del objeto y su material.",
  "recommendation": "Instrucciones de disposición final.",
  "aliases": ["alias1", "alias2"]
}
```

### Colores de contenedor disponibles

| Color | Uso |
|-------|-----|
| Amarillo | Plásticos, metales (empaques) |
| Azul | Papel, cartón limpio |
| Verde | Orgánicos, compostaje |
| Blanco | Vidrio, metales limpios |
| Negro | Residuos no reciclables |
| Rojo | Residuos peligrosos |

---

## Cómo entrenar un nuevo modelo

### 1. Preparar el dataset

Usa un dataset como **Fruits-360**, **Garbage Classification**, o uno personalizado. Estructura:

```
dataset/
├── train/
│   ├── plastic_bottle/
│   │   ├── img1.jpg
│   │   └── img2.jpg
│   ├── glass_bottle/
│   │   └── ...
│   └── ...
└── validation/
    └── ...
```

### 2. Entrenar con transfer learning

```python
import tensorflow as tf

# Cargar MobileNetV3 pre-entrenado
base_model = tf.keras.applications.MobileNetV3Large(
    input_shape=(224, 224, 3),
    include_top=False,
    weights='imagenet'
)

# Congelar capas base
base_model.trainable = False

# Agregar capas de clasificación
model = tf.keras.Sequential([
    base_model,
    tf.keras.layers.GlobalAveragePooling2D(),
    tf.keras.layers.Dense(256, activation='relu'),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(num_classes, activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# Entrenar
model.fit(
    train_dataset,
    validation_data=val_dataset,
    epochs=20,
    callbacks=[
        tf.keras.callbacks.EarlyStopping(patience=5),
        tf.keras.callbacks.ReduceLROnPlateau()
    ]
)
```

### 3. Exportar a TensorFlow Lite

```python
import tensorflow as tf

# Convertir a TFLite cuantizado INT8
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# Dataset de representación para calibración cuantización
def representative_dataset():
    for images, _ in train_dataset.take(100):
        yield [tf.cast(images, tf.float32)]

converter.representative_dataset = representative_dataset
converter.target_spec.supported_types = [tf.int8]

tflite_model = converter.convert()

# Guardar
with open('mobilenet_v3_large.tflite', 'wb') as f:
    f.write(tflite_model)

print(f"Modelo exportado: {len(tflite_model) / 1024:.1f} KB")
```

### 4. Generar labels.txt

```python
# Generar archivo de etiquetas
labels = sorted(class_names)
with open('labels.txt', 'w') as f:
    for label in labels:
        f.write(f"{label}\n")
```

---

## Estructura de assets

```
assets/
├── models/
│   └── mobilenet_v3_large.tflite    # Modelo TFLite (descargar)
├── labels/
│   └── labels.txt                   # Etiquetas del modelo
├── images/
│   └── placeholder.txt              # Placeholder
└── json/
    └── recycle_rules.json           # Base de conocimiento (31 objetos)
```

---

## Flujo de la aplicación

```
Pantalla Principal
       │
       ▼
┌─────────────┐     ┌──────────────┐
│  Cámara     │  o  │   Galería    │
└──────┬──────┘     └──────┬───────┘
       │                   │
       └────────┬──────────┘
                │
                ▼
    ┌───────────────────────┐
    │  Redimensionar imagen │
    └───────────┬───────────┘
                │
                ▼
    ┌───────────────────────┐
    │  Preprocesamiento     │
    │  (RGB float normalize)│
    └───────────┬───────────┘
                │
                ▼
    ┌───────────────────────┐
    │  MobileNetV3 Large    │
    │  (TensorFlow Lite)    │
    └───────────┬───────────┘
                │
                ▼
    ┌───────────────────────┐
    │  Buscar en base       │
    │  de conocimiento      │
    └───────────┬───────────┘
                │
                ▼
    ┌───────────────────────┐
    │  Mostrar resultado:   │
    │  • Objeto detectado   │
    │  • Material           │
    │  • Confianza          │
    │  • Reciclable/Sí-No   │
    │  • Reutilizable/Sí-No │
    │  • Color contenedor   │
    │  • Descripción        │
    │  • Recomendación      │
    └───────────────────────┘
```

---

## Optimizaciones implementadas

- **Inferencia asíncrona**: La clasificación se ejecuta sin bloquear la UI
- **Gestión de memoria**: Liberación de `Interpreter` y `CameraController` en dispose
- **Búsqueda flexible**: Normalización de texto y coincidencia parcial en base de conocimiento
- **Singleton**: Servicios con una sola instancia para evitar duplicación de recursos
- **Lazy loading**: Modelo y base de conocimiento se cargan bajo demanda

---

## Notas para futuras versiones

- [ ] Soporte para detección de múltiples objetos (YOLOv8 TFLite)
- [ ] Clasificación por tipos de plástico (PET, HDPE, PVC, LDPE, PP, PS)
- [ ] Historial de análisis con SQLite
- [ ] Modo offline mejorado con caché de resultados
- [ ] Soporte para modelos personalizados del usuario
- [ ] Animaciones de transición entre pantallas
- [ ] Modo oscuro optimizado
- [ ] Soporte multiidioma (Español/Inglés)

---

## Licencia

MIT License

---

## Autor

rECOCam - Desarrollado con Flutter, TensorFlow Lite y Clean Architecture
