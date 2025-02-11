# 🏍️ **MotoManager - Aplicación de Gestión para Talleres Mecánicos** 🚀

## 📌 **Descripción**
**MotoManager** es una aplicación multiplataforma desarrollada en **Flutter**, diseñada para la gestión de talleres mecánicos. Su propósito es permitir a los mecánicos administrar clientes, motos, inventario, tareas y facturación de manera eficiente y accesible desde dispositivos móviles.

### 🔗 **Integración con la versión de escritorio**
MotoManager es la versión móvil de un **software de escritorio desarrollado en Java Swing**, el cual cuenta con funcionalidades avanzadas como:
- **Generación automática de facturas**  
- **Administración detallada del taller**  
- **Gestión avanzada de clientes,mecanicos y vehículos**  
- **Reportes más completos**  

Ambas versiones (móvil y escritorio) están **sincronizadas con la misma base de datos en Supabase**, permitiendo gestionar los datos en cualquier plataforma.

---

## 🚀 **Características de la Aplicación Móvil**
✅ **Gestión de Clientes:** Registro y administración de clientes con información detallada.  
✅ **Administración de Motos:** Vinculación de motos con clientes y almacenamiento de imágenes del vehículo.  
✅ **Gestión de Inventario:** Control de stock de piezas y repuestos con posibilidad de visualizar movimientos de stock.  
✅ **Gestión de Tareas:** Sistema **Kanban** para organizar trabajos en pendientes, en proceso y completados.  
✅ **Facturación:** Visualización de facturas asociadas a clientes y motos con detalles de servicio.  
✅ **Carga de Imágenes:** Subida de fotos de reparaciones y vehículos al almacenamiento en la nube.  
✅ **Estadísticas del Taller:** Resumen de ingresos, facturas generadas y clientes registrados.  
✅ **Autenticación Segura:** Login y registro de usuarios con **Supabase Authentication**.  
✅ **Modo Oscuro/Claro:** Permite cambiar el tema entre claro y oscuro desde la barra de navegación.  
✅ **Caché de Datos:** Uso de **Hive** y **Shared Preferences** para minimizar consultas a la base de datos.  

---

## 🛠️ **Tecnologías Utilizadas**
- **Flutter & Dart** (Framework de desarrollo multiplataforma)
- **Supabase** (Base de datos PostgreSQL y backend)
- **Provider** (Gestión de estado)
- **Hive** (Almacenamiento en caché local)
- **Figma** (Diseño UI/UX)
- **Image Picker** (Captura y subida de imágenes)

---

## 📸 **Capturas de Pantalla**

<h3>📌 Base de Datos</h3>
<img src="https://github.com/user-attachments/assets/162d133a-a415-4aa5-a208-38f6c3c9fe65" width="450"/>

<h3>📌 Interfaz de la Aplicación</h3>
<img src="https://github.com/user-attachments/assets/e868f4e5-b9fb-4868-a89b-15bb9f7a6e7d" width="450"/>
<img src="https://github.com/user-attachments/assets/26d0e4fa-1c4c-43c3-80b0-bec48dd74fb6" width="450"/>
<img src="https://github.com/user-attachments/assets/8b0a5b92-fce3-463f-89ef-b8f7da55bc9b" width="450"/>
<img src="https://github.com/user-attachments/assets/ef3fafab-e348-436f-8bdc-a01e1ec21e46" width="450"/>
<img src="https://github.com/user-attachments/assets/c3740ae6-29ec-47ab-9d93-8940fe6a41a8" width="450"/>
<img src="https://github.com/user-attachments/assets/9a27e00f-a6e2-4e7c-8de6-a39177d24ea4" width="450"/>
<img src="https://github.com/user-attachments/assets/8a607bc9-7fd7-493b-b0bf-1706520abf99" width="450"/>
<img src="https://github.com/user-attachments/assets/ed4087db-d875-4204-9293-9810595e7c00" width="450"/>
<img src="https://github.com/user-attachments/assets/106c5ccd-74a4-4865-91ec-f9caf64eca1c" width="450"/>
<img src="https://github.com/user-attachments/assets/46bc170e-e48b-499d-b758-a2bc104ccfde" width="450"/>
<img src="https://github.com/user-attachments/assets/d5999155-3ede-4f36-96b7-b8cf81306060" width="450"/>
<img src="https://github.com/user-attachments/assets/1ac81985-6181-41a2-972e-3a076cfdf6f5" width="450"/>
<img src="https://github.com/user-attachments/assets/72e0d103-3990-4272-a0c1-e22a181b4bed" width="450"/>
<img src="https://github.com/user-attachments/assets/7e30c85c-2555-446d-81b3-61ad504bf16f" width="450"/>

---

## 🛠 **Instalación y Configuración**
### **Requisitos Previos**
- Tener instalado Flutter: [Instalar Flutter](https://flutter.dev/docs/get-started/install)
- Tener una cuenta en **Supabase** para gestionar la base de datos y crear la base de datos.
- Tener configurado el **programa de escritorio en Java Swing** si deseas usar ambas versiones en conjunto.

### **Clonar el repositorio**
```bash
git clone https://github.com/tuusuario/motomanager-flutter.git
cd motomanager-flutter
```

### **Instalar dependencias**
```bash
flutter pub get
```

### **Configurar credenciales de Supabase**
Crea un archivo `.env` y coloca tus credenciales, ahora mismo estan en plano en el main, pero es recomendable y necesario en un entorno de producción usar un .env:
```
SUPABASE_URL=https://tusupabaseurl.supabase.co
SUPABASE_ANON_KEY=tu_clave_anonima
```

### **Ejecutar la aplicación**
```bash
flutter run
```

---

## 📌 **Estructura del Proyecto**
```
lib/
│── main.dart                 # Punto de entrada de la aplicación
│── ClientesScreen.dart        # Gestión de clientes
│── InventarioScreen.dart      # Administración de inventario
│── KanbanScreen.dart          # Gestión de tareas en Kanban
│── EstadisticasScreen.dart    # Resumen y reportes estadísticos
│── GalleryScreen.dart         # Visualización de imágenes subidas
│── UploadScreen.dart          # Subida de imágenes de vehículos
│── TareasScreen.dart          # Gestión de tareas del taller
```

---

## 📜 **Licencia**
Este proyecto está bajo la licencia **Creative Commons Zero v1.0 Universal**.

---

## 🤝 **Contribuciones**
Si deseas mejorar la aplicación o reportar un error, ¡las contribuciones son bienvenidas! Puedes abrir un **issue** o hacer un **pull request**.

📩 **Contacto:** Si tienes preguntas o sugerencias, contáctame en cruanesgaspar@gmail.com. 🚀

