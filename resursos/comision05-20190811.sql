-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 11-08-2019 a las 18:56:19
-- Versión del servidor: 10.1.35-MariaDB
-- Versión de PHP: 7.2.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `comision05`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarPar` (IN `vnombre` VARCHAR(45), `vhas_sembradas` VARCHAR(12), `vtotal_has` VARCHAR(50), `vdescripcion` VARCHAR(45), `vtipo` VARCHAR(15))  BEGIN
/*DECLARE nombre varchar(45)*/
INSERT INTO parcela (nombre,has_sembradas,total_has) VALUES (vnombre,vhas_sembradas,vtotal_has);
INSERT INTO reparto (descripcion,tipo) VALUES (vdescripcion,vtipo);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cant_por_reparto` ()  NO SQL
SELECT  DISTINCT
	re.id_reparto as id,
	re.fecha_reparto as fecha,
    (SELECT COUNT(*) FROM orden_riego WHERE id_reparto = re.id_reparto) as cantidad
FROM reparto re
inner join orden_riego orr
	on orr.id_reparto=re.id_reparto$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_hoja_asistencia` (IN `id_asmb` INT)  BEGIN
SET lc_time_names = 'es_ES';
SELECT  
        ha.id_hoja_asistencia as Item,
        CONCAT( a.first_name,' ',a.last_name) as usuario,
        ha.estado as estado,
        Date_format(ha.hora,'%h:%i %p')as hora
     
FROM hoja_asistencia ha
INNER JOIN auth_user a
	ON a.id=ha.id_auth_user
WHERE ha.id_asamblea = id_asmb
ORDER BY ha.estado, ha.hora;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_imprimir_ordenes` (IN `id_repar` INT)  BEGIN
SET lc_time_names = 'es_ES';
SELECT 	
		r.tipo as tipo,
        ord.id_orden_riego as recibo,
        r.fecha_reparto as fecha_reparto,
        c.nombre as canal,
        CONCAT(UPPER(u.last_name),', ',SUBSTRING_INDEX(u.first_name, ' ',1))  as usuario,
        p.nombre as parcela,
        p.num_toma as toma,
        Date_format(ord.fecha_inicio,'%Y/%M/%d') as fecha,
        Date_format(ord.fecha_inicio,'%h:%i %p')as inicio,
        ord.duracion as horas,
        CONCAT('S/. ',ord.importe) as importe
FROM orden_riego ord
INNER JOIN  reparto r
	on r.id_reparto=ord.id_reparto
INNER JOIN parcela p
	ON ord.id_parcela=p.id_parcela
INNER JOIN auth_user u
	ON p.id_auth_user=u.id
INNER JOIN canal c
	ON p.id_canal=c.id_canal
WHERE r.id_reparto = id_repar and ord.estado='Entregada'
ORDER BY c.id_canal,p.num_toma,u.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_imp_orden` (IN `id_ord` INT)  BEGIN
SET lc_time_names = 'es_ES';
SELECT  
        r.tipo as tipo,
        ord.id_orden_riego as recibo,
        r.fecha_reparto as fecha_reparto,
        c.nombre as canal,
        CONCAT(UPPER(u.last_name),', ',SUBSTRING_INDEX(u.first_name, ' ',1))  as usuario,
        p.nombre as parcela,
        p.num_toma as toma,
        Date_format(ord.fecha_inicio,'%Y/%M/%d') as fecha,
        Date_format(ord.fecha_inicio,'%h:%i %p')as inicio,
        ord.duracion as horas,
        CONCAT('S/. ',ord.importe) as importe
FROM orden_riego ord
INNER JOIN  reparto r
    on r.id_reparto=ord.id_reparto
INNER JOIN parcela p
    ON ord.id_parcela=p.id_parcela
INNER JOIN auth_user u
    ON p.id_auth_user=u.id
INNER JOIN canal c
    ON p.id_canal=c.id_canal
WHERE ord.id_orden_riego = id_ord;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_jugando1` (IN `id_repar` INT)  BEGIN
	DECLARE fecha date ;
	DECLARE cont int;
    DECLARE ids int;
    SET ids = (SELECT id_orden_riego from orden_riego WHERE id_orden_riego = (SELECT min(id_orden_riego) from orden_riego));
    SET cont = (SELECT COUNT(*) from orden_riego WHERE id_reparto = id_repar);
    set fecha = (SELECT fecha_inicio 
                 from orden_riego 
                 WHERE id_orden_riego=(select min(id_orden_riego) from orden_riego) and id_reparto = id_repar);
                    
    WHILE cont> 0 DO    	
      SELECT * FROM orden_riego WHERE id_orden_riego = ids;
      SET ids = ids +1;
      SET cont = cont - 1 ;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ordenes_por_reparto_por_canal` ()  NO SQL
SELECT  DISTINCT
	re.id_reparto as id_reparto,
	re.fecha_reparto as fecha,
    ca.nombre as canal,
    ca.id_canal as id_canal,
    (SELECT COUNT(*) FROM orden_riego WHERE id_reparto = re.id_reparto and pa.id_canal= ca.id_canal) as cantidad
FROM reparto re
inner join orden_riego orr
	on orr.id_reparto=re.id_reparto
inner join parcela pa
	on pa.id_parcela = orr.id_parcela
inner join canal ca 
	on ca.id_canal = pa.id_canal
order by re.id_reparto,ca.id_canal$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_prueba` ()  BEGIN
 DECLARE v1 INT DEFAULT 5;
 DECLARE tam int;
 SET @tam = (SELECT COUNT(*) FROM datos_personales);

  WHILE v1 > 0 DO
    SELECT v1 as V11;
    set v1 = v1 -1;
  END WHILE;
  
  SELECT @tam as TAMM;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registro_rapido` (IN `vnombres` VARCHAR(30), `vapellidos` VARCHAR(150), `valias` VARCHAR(20), `vcelular` CHAR(13), `vdni` CHAR(8), `vfecha_nacimiento` DATE, `vfoto` VARCHAR(150), `vsexo` CHAR(1), `vtelefono` VARCHAR(20))  BEGIN
	DECLARE Id int;
    DECLARE vusername varchar(150);
    DECLARE vcontrasena varchar(128);
    
    set vusername = vdni;
    set vcontrasena = vdni;
    
    INSERT INTO auth_user(first_name,last_name,username,password) 
    	VALUES (vnombres,vapellidos,vusername,vcontrasena);
    
    set Id = (SELECT id FROM auth_user ORDER BY id DESC LIMIT 1);
    set vusername = vdni;

    INSERT INTO datos_personales(alias,celular,dni,fecha_nacimiento,foto,id_auth_user,sexo,telefono) 
        VALUES(valias,vcelular,vdni,vfecha_nacimiento,vfoto,Id,vsexo,vtelefono);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reparto_rep` (IN `idr` INT)  BEGIN
SET lc_time_names = 'es_ES';
SELECT 
        ord.id_orden_riego as recibo,
        c.nombre as canal,
        p.num_toma as toma,
        p.nombre as parcela,
        CONCAT(UPPER(u.last_name),', ',SUBSTRING_INDEX(u.first_name, ' ',1))  as usuario,
        Date_format(ord.fecha_inicio,'%Y/%M/%d') as fecha,
        Date_format(ord.fecha_inicio,'%h:%i %p')as inicio,
        ord.duracion as horas,
       	ord.importe as importe,
        ord.estado as estado
FROM orden_riego ord
INNER JOIN parcela p
	ON ord.id_parcela=p.id_parcela
INNER JOIN auth_user u
	ON p.id_auth_user=u.id
INNER JOIN canal c
	ON p.id_canal=c.id_canal
WHERE ord.id_reparto = idr
ORDER BY c.id_canal,p.num_toma,u.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rep_disponibles` ()  NO SQL
SELECT * FROM reparto re 
    WHERE re.estado = 2 ORDER BY re.fecha_reparto, re.tipo$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rep_reparto` ()  NO SQL
SELECT 
	re.tipo as reparto,
	ord.id_orden_riego as id_orden,
    pa.num_toma as toma,
    ord.fecha_establecida as fecha,
    ord.duracion as hectareas,
    ca.nombre as canal,
    au.first_name as usuario   
FROM orden_riego ord

INNER JOIN parcela pa
 ON ord.id_parcela = pa.id_parcela
 
INNER JOIN canal ca
	ON ca.id_canal = pa.id_canal
    
INNER JOIN auth_user au 
	ON pa.id_auth_user=au.id
    
INNER JOIN reparto re
	ON ord.id_reparto=re.id_reparto
    
ORDER BY re.tipo ,ca.id_canal,pa.num_toma$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `agenda_asamblea`
--

CREATE TABLE `agenda_asamblea` (
  `id_agenda` int(11) NOT NULL,
  `id_asamblea` int(11) DEFAULT NULL,
  `punto_numero` int(11) DEFAULT NULL,
  `descripcion` varchar(400) COLLATE hp8_bin DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `agenda_asamblea`
--

INSERT INTO `agenda_asamblea` (`id_agenda`, `id_asamblea`, `punto_numero`, `descripcion`, `foto`) VALUES
(37, 62, 2, '1.- xsaDSAdsa', NULL),
(38, 62, 2, '2.- DSADSA', NULL),
(40, 65, 1, '1.- fdwfrew', NULL),
(42, 68, 1, '1.- 555', NULL),
(43, 69, 1, '1.- De todo un poco.', NULL),
(44, 71, 1, '1.- aadssd', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `archivos_parcela`
--

CREATE TABLE `archivos_parcela` (
  `id_archivos_parcela` int(11) NOT NULL,
  `id_parcela` int(11) DEFAULT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `archivo` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asamblea`
--

CREATE TABLE `asamblea` (
  `id_asamblea` int(11) NOT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `descripcion` varchar(300) COLLATE hp8_bin DEFAULT NULL,
  `fecha_registro` datetime DEFAULT NULL,
  `fecha_asamblea` datetime DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `asamblea`
--

INSERT INTO `asamblea` (`id_asamblea`, `tipo`, `descripcion`, `fecha_registro`, `fecha_asamblea`, `estado`) VALUES
(62, 'General', 'Una buena descripción.', '2019-07-29 02:41:21', '2019-07-08 12:12:00', '3'),
(65, 'General', 'fefreqwfer', '2019-07-29 03:09:15', '2019-07-30 12:12:00', '2'),
(68, 'General', 'Acá ponemos una bonita descripción pues.', '2019-07-29 04:21:36', '2019-07-08 05:05:00', '2'),
(69, 'General', 'Asamblea general.', '2019-07-30 00:12:22', '2019-07-31 12:12:00', '3'),
(71, 'General', 'ddd', '2019-08-01 01:32:57', '2019-08-09 12:12:00', '3');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(150) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `name` varchar(255) COLLATE hp8_bin NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 2, 'add_permission'),
(6, 'Can change permission', 2, 'change_permission'),
(7, 'Can delete permission', 2, 'delete_permission'),
(8, 'Can view permission', 2, 'view_permission'),
(9, 'Can add group', 3, 'add_group'),
(10, 'Can change group', 3, 'change_group'),
(11, 'Can delete group', 3, 'delete_group'),
(12, 'Can view group', 3, 'view_group'),
(13, 'Can add user', 4, 'add_user'),
(14, 'Can change user', 4, 'change_user'),
(15, 'Can delete user', 4, 'delete_user'),
(16, 'Can view user', 4, 'view_user'),
(17, 'Can add content type', 5, 'add_contenttype'),
(18, 'Can change content type', 5, 'change_contenttype'),
(19, 'Can delete content type', 5, 'delete_contenttype'),
(20, 'Can view content type', 5, 'view_contenttype'),
(21, 'Can add session', 6, 'add_session'),
(22, 'Can change session', 6, 'change_session'),
(23, 'Can delete session', 6, 'delete_session'),
(24, 'Can view session', 6, 'view_session'),
(25, 'Can add acceso', 7, 'add_acceso'),
(26, 'Can change acceso', 7, 'change_acceso'),
(27, 'Can delete acceso', 7, 'delete_acceso'),
(28, 'Can view acceso', 7, 'view_acceso'),
(29, 'Can add asamblea', 8, 'add_asamblea'),
(30, 'Can change asamblea', 8, 'change_asamblea'),
(31, 'Can delete asamblea', 8, 'delete_asamblea'),
(32, 'Can view asamblea', 8, 'view_asamblea'),
(33, 'Can add asistencia', 9, 'add_asistencia'),
(34, 'Can change asistencia', 9, 'change_asistencia'),
(35, 'Can delete asistencia', 9, 'delete_asistencia'),
(36, 'Can view asistencia', 9, 'view_asistencia'),
(37, 'Can add canal', 10, 'add_canal'),
(38, 'Can change canal', 10, 'change_canal'),
(39, 'Can delete canal', 10, 'delete_canal'),
(40, 'Can view canal', 10, 'view_canal'),
(41, 'Can add caudal', 11, 'add_caudal'),
(42, 'Can change caudal', 11, 'change_caudal'),
(43, 'Can delete caudal', 11, 'delete_caudal'),
(44, 'Can view caudal', 11, 'view_caudal'),
(45, 'Can add comite', 12, 'add_comite'),
(46, 'Can change comite', 12, 'change_comite'),
(47, 'Can delete comite', 12, 'delete_comite'),
(48, 'Can view comite', 12, 'view_comite'),
(49, 'Can add comprobante', 13, 'add_comprobante'),
(50, 'Can change comprobante', 13, 'change_comprobante'),
(51, 'Can delete comprobante', 13, 'delete_comprobante'),
(52, 'Can view comprobante', 13, 'view_comprobante'),
(53, 'Can add destajo', 14, 'add_destajo'),
(54, 'Can change destajo', 14, 'change_destajo'),
(55, 'Can delete destajo', 14, 'delete_destajo'),
(56, 'Can view destajo', 14, 'view_destajo'),
(57, 'Can add det limpieza', 15, 'add_detlimpieza'),
(58, 'Can change det limpieza', 15, 'change_detlimpieza'),
(59, 'Can delete det limpieza', 15, 'delete_detlimpieza'),
(60, 'Can view det limpieza', 15, 'view_detlimpieza'),
(61, 'Can add det lista', 16, 'add_detlista'),
(62, 'Can change det lista', 16, 'change_detlista'),
(63, 'Can delete det lista', 16, 'delete_detlista'),
(64, 'Can view det lista', 16, 'view_detlista'),
(65, 'Can add direccion', 17, 'add_direccion'),
(66, 'Can change direccion', 17, 'change_direccion'),
(67, 'Can delete direccion', 17, 'delete_direccion'),
(68, 'Can view direccion', 17, 'view_direccion'),
(69, 'Can add limpieza', 18, 'add_limpieza'),
(70, 'Can change limpieza', 18, 'change_limpieza'),
(71, 'Can delete limpieza', 18, 'delete_limpieza'),
(72, 'Can view limpieza', 18, 'view_limpieza'),
(73, 'Can add lista', 19, 'add_lista'),
(74, 'Can change lista', 19, 'change_lista'),
(75, 'Can delete lista', 19, 'delete_lista'),
(76, 'Can view lista', 19, 'view_lista'),
(77, 'Can add multa', 20, 'add_multa'),
(78, 'Can change multa', 20, 'change_multa'),
(79, 'Can delete multa', 20, 'delete_multa'),
(80, 'Can view multa', 20, 'view_multa'),
(81, 'Can add noticia', 21, 'add_noticia'),
(82, 'Can change noticia', 21, 'change_noticia'),
(83, 'Can delete noticia', 21, 'delete_noticia'),
(84, 'Can view noticia', 21, 'view_noticia'),
(85, 'Can add obra', 22, 'add_obra'),
(86, 'Can change obra', 22, 'change_obra'),
(87, 'Can delete obra', 22, 'delete_obra'),
(88, 'Can view obra', 22, 'view_obra'),
(89, 'Can add orden riego', 23, 'add_ordenriego'),
(90, 'Can change orden riego', 23, 'change_ordenriego'),
(91, 'Can delete orden riego', 23, 'delete_ordenriego'),
(92, 'Can view orden riego', 23, 'view_ordenriego'),
(93, 'Can add parcela', 24, 'add_parcela'),
(94, 'Can change parcela', 24, 'change_parcela'),
(95, 'Can delete parcela', 24, 'delete_parcela'),
(96, 'Can view parcela', 24, 'view_parcela'),
(97, 'Can add persona', 25, 'add_persona'),
(98, 'Can change persona', 25, 'change_persona'),
(99, 'Can delete persona', 25, 'delete_persona'),
(100, 'Can view persona', 25, 'view_persona'),
(101, 'Can add reparto', 26, 'add_reparto'),
(102, 'Can change reparto', 26, 'change_reparto'),
(103, 'Can delete reparto', 26, 'delete_reparto'),
(104, 'Can view reparto', 26, 'view_reparto'),
(105, 'Can add talonario', 27, 'add_talonario'),
(106, 'Can change talonario', 27, 'change_talonario'),
(107, 'Can delete talonario', 27, 'delete_talonario'),
(108, 'Can view talonario', 27, 'view_talonario'),
(109, 'Can add usuario', 28, 'add_usuario'),
(110, 'Can change usuario', 28, 'change_usuario'),
(111, 'Can delete usuario', 28, 'delete_usuario'),
(112, 'Can view usuario', 28, 'view_usuario'),
(113, 'Can add agenda asamblea', 29, 'add_agendaasamblea'),
(114, 'Can change agenda asamblea', 29, 'change_agendaasamblea'),
(115, 'Can delete agenda asamblea', 29, 'delete_agendaasamblea'),
(116, 'Can view agenda asamblea', 29, 'view_agendaasamblea'),
(117, 'Can add archivos parcela', 30, 'add_archivosparcela'),
(118, 'Can change archivos parcela', 30, 'change_archivosparcela'),
(119, 'Can delete archivos parcela', 30, 'delete_archivosparcela'),
(120, 'Can view archivos parcela', 30, 'view_archivosparcela'),
(121, 'Can add auth group', 31, 'add_authgroup'),
(122, 'Can change auth group', 31, 'change_authgroup'),
(123, 'Can delete auth group', 31, 'delete_authgroup'),
(124, 'Can view auth group', 31, 'view_authgroup'),
(125, 'Can add auth group permissions', 32, 'add_authgrouppermissions'),
(126, 'Can change auth group permissions', 32, 'change_authgrouppermissions'),
(127, 'Can delete auth group permissions', 32, 'delete_authgrouppermissions'),
(128, 'Can view auth group permissions', 32, 'view_authgrouppermissions'),
(129, 'Can add auth permission', 33, 'add_authpermission'),
(130, 'Can change auth permission', 33, 'change_authpermission'),
(131, 'Can delete auth permission', 33, 'delete_authpermission'),
(132, 'Can view auth permission', 33, 'view_authpermission'),
(133, 'Can add auth user', 34, 'add_authuser'),
(134, 'Can change auth user', 34, 'change_authuser'),
(135, 'Can delete auth user', 34, 'delete_authuser'),
(136, 'Can view auth user', 34, 'view_authuser'),
(137, 'Presidente', 34, 'es_presidente'),
(138, 'Canalero', 34, 'es_canalero'),
(139, 'Tesorero', 34, 'es_tesorero'),
(140, 'Vocal', 34, 'es_vocal'),
(141, 'Usuario', 34, 'es_usuario'),
(142, 'Can add auth user groups', 35, 'add_authusergroups'),
(143, 'Can change auth user groups', 35, 'change_authusergroups'),
(144, 'Can delete auth user groups', 35, 'delete_authusergroups'),
(145, 'Can view auth user groups', 35, 'view_authusergroups'),
(146, 'Can add auth user user permissions', 36, 'add_authuseruserpermissions'),
(147, 'Can change auth user user permissions', 36, 'change_authuseruserpermissions'),
(148, 'Can delete auth user user permissions', 36, 'delete_authuseruserpermissions'),
(149, 'Can view auth user user permissions', 36, 'view_authuseruserpermissions'),
(150, 'Can add datos personales', 37, 'add_datospersonales'),
(151, 'Can change datos personales', 37, 'change_datospersonales'),
(152, 'Can delete datos personales', 37, 'delete_datospersonales'),
(153, 'Can view datos personales', 37, 'view_datospersonales'),
(154, 'Can add django admin log', 38, 'add_djangoadminlog'),
(155, 'Can change django admin log', 38, 'change_djangoadminlog'),
(156, 'Can delete django admin log', 38, 'delete_djangoadminlog'),
(157, 'Can view django admin log', 38, 'view_djangoadminlog'),
(158, 'Can add django content type', 39, 'add_djangocontenttype'),
(159, 'Can change django content type', 39, 'change_djangocontenttype'),
(160, 'Can delete django content type', 39, 'delete_djangocontenttype'),
(161, 'Can view django content type', 39, 'view_djangocontenttype'),
(162, 'Can add django migrations', 40, 'add_djangomigrations'),
(163, 'Can change django migrations', 40, 'change_djangomigrations'),
(164, 'Can delete django migrations', 40, 'delete_djangomigrations'),
(165, 'Can view django migrations', 40, 'view_djangomigrations'),
(166, 'Can add django session', 41, 'add_djangosession'),
(167, 'Can change django session', 41, 'change_djangosession'),
(168, 'Can delete django session', 41, 'delete_djangosession'),
(169, 'Can view django session', 41, 'view_djangosession'),
(170, 'Can add hoja asistencia', 42, 'add_hojaasistencia'),
(171, 'Can change hoja asistencia', 42, 'change_hojaasistencia'),
(172, 'Can delete hoja asistencia', 42, 'delete_hojaasistencia'),
(173, 'Can view hoja asistencia', 42, 'view_hojaasistencia'),
(174, 'Can add comp multa', 43, 'add_compmulta'),
(175, 'Can change comp multa', 43, 'change_compmulta'),
(176, 'Can delete comp multa', 43, 'delete_compmulta'),
(177, 'Can view comp multa', 43, 'view_compmulta'),
(178, 'Can add comp orden', 44, 'add_comporden'),
(179, 'Can change comp orden', 44, 'change_comporden'),
(180, 'Can delete comp orden', 44, 'delete_comporden'),
(181, 'Can view comp orden', 44, 'view_comporden'),
(182, 'Can add multa asistencia', 45, 'add_multaasistencia'),
(183, 'Can change multa asistencia', 45, 'change_multaasistencia'),
(184, 'Can delete multa asistencia', 45, 'delete_multaasistencia'),
(185, 'Can view multa asistencia', 45, 'view_multaasistencia'),
(186, 'Can add multa limpia', 46, 'add_multalimpia'),
(187, 'Can change multa limpia', 46, 'change_multalimpia'),
(188, 'Can delete multa limpia', 46, 'delete_multalimpia'),
(189, 'Can view multa limpia', 46, 'view_multalimpia'),
(190, 'Can add multa orden', 47, 'add_multaorden'),
(191, 'Can change multa orden', 47, 'change_multaorden'),
(192, 'Can delete multa orden', 47, 'delete_multaorden'),
(193, 'Can view multa orden', 47, 'view_multaorden'),
(194, 'Can add det asamb canal', 48, 'add_detasambcanal'),
(195, 'Can change det asamb canal', 48, 'change_detasambcanal'),
(196, 'Can delete det asamb canal', 48, 'delete_detasambcanal'),
(197, 'Can view det asamb canal', 48, 'view_detasambcanal');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user`
--

CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL,
  `password` varchar(128) COLLATE hp8_bin NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE hp8_bin NOT NULL,
  `first_name` varchar(30) COLLATE hp8_bin NOT NULL,
  `last_name` varchar(150) COLLATE hp8_bin NOT NULL,
  `email` varchar(254) COLLATE hp8_bin NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `dni` varchar(8) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `auth_user`
--

INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `first_name`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `dni`) VALUES
(1, 'pbkdf2_sha256$150000$9PjEvjWaocDj$YeVw0RMguNFrLWwIzPnF5P2RzZD3rBvg7pFNaApaUh8=', '2019-08-11 00:16:46.455421', 1, 'grcl', 'Geral R', '[Desarrollador]', 'lareg.yors@gmail.com', 1, 1, '2018-10-24 13:32:59.769234', '76583884'),
(2, 'pbkdf2_sha256$150000$3125dCTPvjNy$x6ITkc93/Z3ZOHrg0aIleKhGif4j0GJkeGCtBkOmru4=', '2019-08-06 00:20:26.073593', 0, 'Presidente', 'Domingo Pelayo', 'Sanchez Vilchez', 'dpelayo@gmail.com', 0, 1, '2018-10-24 13:55:47.000000', '27911359'),
(3, 'pbkdf2_sha256$150000$Lq2U2CmDOGIJ$/PxKCL2Wcwp+Laxeci08WqiU5Q6Ox/r1De6BU3uyLcs=', '2019-08-06 00:22:39.719096', 0, 'Canalero', 'Saul', 'Cieza', 'scieza@hotmail.com', 0, 1, '2018-10-24 13:57:47.000000', '10000007'),
(5, 'pbkdf2_sha256$120000$iq4pABZBLoQ1$z4W+Bhp0w90w9KUyqgHr3Ox/0xtRDp2GP3iMg7bekc8=', '2019-02-13 21:29:24.969332', 0, 'Vocal', 'Roger', 'Gonzales Chuan', 'rgonzales@gmail.com', 0, 1, '2018-10-24 21:54:31.409353', '45939181'),
(6, 'pbkdf2_sha256$150000$PPVjvSiJsRQV$Z0jTJKg0s35D5eOeAAkgmSAmTSF6tYnVzTZNDho93CM=', '2019-07-29 07:14:03.834397', 0, 'paredes@27916871', 'María Consuelo ', 'Paredes DÍaz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916871'),
(7, 'pbkdf2_sha256$150000$Y3J6Ywytsb7t$kvd+7HvmkQftiCJWdVgSZS06F0oFw6+Pvd7OiElB1sg=', '2019-07-29 07:17:50.434758', 0, 'pereda@27920554', 'Josué Ramón ', 'Pereda Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27920554'),
(8, 'pbkdf2_sha256$150000$7l9EuVGu95ug$8QL91ONA8ysX5NsR71PFJHa5HUWB/qxlv1ztwKpocyU=', '2019-08-06 04:38:05.110316', 0, 'arbildo@44500169', 'Julio Henry ', 'Arbildo Chavarry', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44500169'),
(9, 'pbkdf2_sha256$150000$s5UBkrV4xET2$1CBWo+WUjuYpApeeoGnIqdalA5ZRxplbqx2d+7a1Xt0=', '2019-08-06 04:37:11.553652', 0, 'tirado@27925153', 'Samuel Porfirio ', 'Tirado Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27925153'),
(10, 'pbkdf2_sha256$150000$9GD5aIUopr8w$9QqBrUEl6caYRJFyyWeXNjFcTI0lo4DdvciuwGelgsA=', '2019-08-06 04:35:44.212174', 0, 'santos@10567740', 'Nicolás Edwin ', 'Santos Arce', 'null', 0, 1, '0000-00-00 00:00:00.000000', '10567740'),
(11, 'pbkdf2_sha256$150000$F0SBYwQBwSsQ$hzyOunDiO3mMqTNzdwEC2skBVDqg+nu9g9GiTOvJ1JA=', '2019-08-06 04:32:55.928944', 0, 'ortiz@27041401', 'Hilda Rosa ', 'Ortiz Cotrina', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27041401'),
(12, 'pbkdf2_sha256$150000$9rnunFu6YGvU$fuY+7+w2QTfjb6XeeKbXuwWn/aMgnRxwEKrLiXOgI14=', '2019-08-08 03:26:07.099080', 0, 'arce@17837106', 'Lina Beatriz ', 'Arce Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17837106'),
(13, 'pbkdf2_sha256$150000$6ex5DKi7409p$9Q9bpdOvuCbgwLrkXJ+hYcssW+EQqhiF8NSu6js1Tbo=', '2019-08-06 04:39:08.566734', 0, 'rojas@08938592', 'José Pablo ', 'Rojas Carrera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '08938592'),
(14, 'pbkdf2_sha256$150000$ImXQv5U7lhlw$4u8qPL1I5vOuMFMTG0We8RQ2MJvh5edibWboonAL6c4=', '2019-08-10 01:42:32.827755', 0, 'mendoza@47701484', 'Augusto Segundo ', 'Mendoza Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47701484'),
(15, 'pbkdf2_sha256$150000$7aSP8cICiO1B$xLOkLiQJRsYn/0vbhZpyAsrf6qwXHDcGI5vO0SAV/8k=', '2019-08-10 02:30:43.167868', 0, 'carrera@17975860', 'José Amado ', 'Carrera Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17975860'),
(16, 'pbkdf2_sha256$150000$AUfyITkRhWhE$uo2WJEW1X2v4/haRlMugd3HGb3GlRFGdJDr4K3DyOrk=', NULL, 0, 'carrera@27901508', 'Mario Herminio ', 'Carrera Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27901508'),
(17, 'pbkdf2_sha256$150000$PpqoRh94dLoZ$Z4pg3x1Z050yDGJ3w6PPu29tdKmVT5IfXEEi1kFtz9g=', NULL, 0, 'abanto@27904969', 'Luis', 'Abanto Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27904969'),
(18, 'pbkdf2_sha256$150000$k8YsfbfPVcDP$S4vC1xJtM/FS4/a6xT8wkZoRgFOcyKKtlqvKgcJ752c=', NULL, 0, 'carrera@27900194', 'Juan de la Cruz', 'Carrera Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27900194'),
(19, 'pbkdf2_sha256$150000$xuSHl3ZyoCsN$o6dZ+CzHDLWWACzogPyv+H/0LNNQIiV7RQV3wZp/5PM=', NULL, 0, 'cotrina@26616098', 'Eladio', 'Cotrina Quispe', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26616098'),
(20, 'pbkdf2_sha256$150000$ISQOZJDrI78f$a3JOJ8xI3+n4RaM5gybMiovyy4JF/8AQehscLNx+LaQ=', NULL, 0, 'sanchez@19328772', 'Jesús Bernardo ', 'Sánchez Paz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19328772'),
(21, 'pbkdf2_sha256$150000$fe3ixo7nL708$/+LLBu2lVgD+sX/q8naSKL+uCKiX9jfiQ6tgrCnvNiM=', NULL, 0, 'cordero@48419583', 'José Luis ', 'Cordero del Pino', 'null', 0, 1, '0000-00-00 00:00:00.000000', '48419583'),
(22, 'pbkdf2_sha256$150000$OI3cmRndDlNd$MXx4519Xv7DpmUkD6JyXTK68RnqFYNfUfvkcj1rReyc=', NULL, 0, 'castañeda@19260042', 'Juana Doraliza ', 'Castañeda Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19260042'),
(23, 'pbkdf2_sha256$150000$xg6jiY7e6kch$4np5SgkwGkT+6hoX3M3CLZbrE4DnzQU9wRPUM/Knv/M=', NULL, 0, 'gonzales@42811950', 'Ceyner', 'Gonzáles Chuan', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42811950'),
(24, 'pbkdf2_sha256$150000$dZJFwfZNmNHj$n1IfxRMhAcZJmAwh6McaFx+9aQ9jMNYX+ck2VNpkMd4=', NULL, 0, 'briones@27916060', 'Pedro', 'Briones Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916060'),
(25, 'pbkdf2_sha256$150000$iXRuQKyA0Rll$qqzH5/VRglca+HMozBhDNO/W81orFxXa7BGBn9EfNOg=', NULL, 0, 'vasquez@07538471', 'Clemente ', 'Vásquez Medina', 'null', 0, 1, '0000-00-00 00:00:00.000000', '07538471'),
(26, 'pbkdf2_sha256$150000$nI6t1F1Y6qb9$qlB3NvMeo61EFFU5690dmrsnYYyS8ZIKwNen9uHJf40=', NULL, 0, 'narva@26729717', 'Sonia Ronnaly ', 'Narva Barrantes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26729717'),
(27, 'pbkdf2_sha256$150000$BooOjuHMztxv$Rok+wWbIwK7z2uAXA3IAOGj1W8v+wr/3llQZHW/I0Jc=', NULL, 0, 'briones@07579160', 'Segundo Félix ', 'Briones Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '07579160'),
(28, 'pbkdf2_sha256$150000$ZGL6KWHDwn8b$Dmd3CasFX/tiDpK6cKtV5nulvdEFUfpFrfyci/M9Drc=', NULL, 0, 'cotrina@25842560', 'José Wilmer ', 'Cotrina Olortegui', 'null', 0, 1, '0000-00-00 00:00:00.000000', '25842560'),
(29, 'pbkdf2_sha256$150000$ztxPbPFCgwIK$GE1Z39C4ruI/+e507AUhE1VjC0fLEfxHF1iWzXmNyNw=', NULL, 0, 'cordova@03382668', 'Balvina ', 'Córdova Mondragón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '03382668'),
(30, 'pbkdf2_sha256$150000$2ZveDR4nz6V5$bcymk8vHOs06NBbJlvgW3R1cwKzmg0CD/GgL+nRNabc=', NULL, 0, 'castañeda@07538471', 'Nelson Rafael ', 'Castañeda Muñoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '07538471'),
(31, 'pbkdf2_sha256$150000$wfvKaVA1endU$51chjNhzevHAbGTXzb1aHRyrEC9GVKKcd+tyQeL9WWE=', NULL, 0, 'lezama@27913786', 'Dominga Elizabet ', 'Lezama Mendoza ', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27913786'),
(32, 'pbkdf2_sha256$150000$J3rpPJ8fzmSb$KZSZzqR/sORNxT74ydUa4TJ04iJwPV5mt7mKlo6jp6o=', NULL, 0, 'olortegui@19260049', 'Segundo Claudio ', 'Olortegui Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19260049'),
(33, 'pbkdf2_sha256$150000$X3l7OijdgvtO$PtpkPReuE7qTJrSVTLQssdqmJWhSh+hJwwCAZ1gqXnM=', NULL, 0, 'castañeda@27911098', 'Regina Tomasa ', 'Castañeda Muñoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911098'),
(34, 'pbkdf2_sha256$150000$wAcXaBBlEPTq$EOQDQrUIfuisAvNNqvy0Y9FQ7d/lduGOJ7Bs0i4lHBc=', NULL, 0, 'sanchez@19258711', 'José Celestino ', 'Sánchez Vargas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19258711'),
(35, 'pbkdf2_sha256$150000$ctOWidXIhqGo$pSbdwFGyKYMdZ7F3OqvlUbJgDjPamwZpFmgrodWOeE8=', NULL, 0, 'correa@26694937', 'Martha Rossana ', 'Correa Cabanillas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26694937'),
(36, 'pbkdf2_sha256$150000$C6bDMMBO8HZm$meXx5VASAXIc/adQVj1EmuuvfWM8sV/a6PQhUXqEGyA=', NULL, 0, 'ramirez@27926644', 'Felécitas ', 'Ramírez Bueno', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926644'),
(37, 'pbkdf2_sha256$150000$XDwWjpBNsqGF$G+c6pUqi814DoEaYVHtG5+6/9QzWDyGWDv7fb7wf6LA=', NULL, 0, 'vasquez@19242421', 'Carmen Rosa ', 'Vásquez  Fernández ', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19242421'),
(38, 'pbkdf2_sha256$150000$kInxhwNCXdei$WwXT4NcT2T4sMo2v4ltNpJPd7ImK6YTlZaeNNqCeP/A=', NULL, 0, 'abanto@27923319', 'Eligio ', 'Abanto Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27923319'),
(39, 'pbkdf2_sha256$150000$ZewZfvhZ05Zf$Up8tqaNjPV9lS0Nl71q85HyKuUVqZMnziSYGltIO6hE=', NULL, 0, 'mendoza@42186329', 'Any Yaneth ', 'Mendoza Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42186329'),
(40, 'pbkdf2_sha256$150000$2IRfWy3oy6n7$kMqlMDx5v6TAOmpUIq0VRut0gdBxBTNMIFSD6rYZuZQ=', NULL, 0, 'briones@27904660', 'Jesús ', 'Briones Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27904660'),
(41, 'pbkdf2_sha256$150000$7Cf2kw3o4gRF$DxTOpUOGDfeXaFesb7rnVV3RtTO2x+poKvnUDIKDD74=', NULL, 0, 'perez@09091088', 'Felicitas ', 'Perez Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '09091088'),
(42, 'pbkdf2_sha256$150000$lU7kwPEedC5z$Vol8bWaxMmd7V3ZZzQAGwbefIwGqkt4Ijlra2rVGoX0=', NULL, 0, 'balarezo@19239343', 'José Antonio ', 'Balarezo Rocha', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19239343'),
(43, 'pbkdf2_sha256$150000$DmmaswwHa02v$BVxRzgtOb9PIw+hGC3U3rosm0wcn0Zm8wBC1qfinqaQ=', NULL, 0, 'vega@17813980', 'María Enma ', 'Vega Rivera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17813980'),
(44, 'pbkdf2_sha256$150000$KsZwy353nRZv$KdHroB5GGJ++J/8beXmxky+KeMLFLGpffGe7EOGH6b0=', NULL, 0, 'mendoza@26640965', 'Graciano ', 'Mendoza Ruiz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26640965'),
(45, 'pbkdf2_sha256$150000$Z6O1t8GeChDI$c/qfD0M3NU7FNER1REMdmUQHpB2qqW7KFn2OEK9QvOM=', NULL, 0, 'sanchez@19420925', 'Inocente ', 'Sánchez Quiroz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19420925'),
(46, 'pbkdf2_sha256$150000$QPL8CDTvcBev$RjI7OpQ2epQj2q9U1+nATHqTDmOcdTJsqDAkXraquvQ=', NULL, 0, 'cotrina@27911107', 'Aldemar Inocencio ', 'Cotrina Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911107'),
(47, 'pbkdf2_sha256$150000$kSLqEjKPO4my$3Jf0Pa4eI1FytFeCAUokWyWOKaM00sXirYO0rNUzO7k=', NULL, 0, 'romero@19261326', 'Segundo Wilmer ', 'Romero Mendoza', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19261326'),
(48, 'pbkdf2_sha256$150000$quweEMajWFbB$eYeW/ca+OnzMPNO+hCL4aFblCF0EPQ5NdE7naq/il+Y=', NULL, 0, 'cleza@26608460', 'Diego Gilberto ', 'Cleza Padilla', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26608460'),
(49, 'pbkdf2_sha256$150000$CBJ5VBFZvxce$7ipEjfJqkxHTl8GO0/f8MSzqgZB0L9fGpmo+k3VytWQ=', NULL, 0, 'abanto@19218235', 'Valentín Severino ', 'Abanto Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19218235'),
(50, 'pbkdf2_sha256$150000$rQEWvmznYuXP$3zw8bcT/YNFovXi9kv43gBxnnR0HbFEwXsf//NcYEDc=', NULL, 0, 'tirado@27921569', 'Gosvinda ', 'Tirado Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27921569'),
(51, 'pbkdf2_sha256$150000$hQTO38nptksJ$ofPztHZ2mAiKYYrYaOrJ8JLtlFSavlA1hjaNT50sjnI=', NULL, 0, 'muñoz@80456957', 'José Jesés ', 'Muñóz Ríos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '80456957'),
(52, 'pbkdf2_sha256$150000$seB2QQDJRUOy$rBgUIS0w7aZ8M8kMc/uURBMxaYQYiW+FzBJQkiyHi8A=', NULL, 0, 'abanto@27928067', 'Ascensión Estanislao ', 'Abanto Moreno', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27928067'),
(53, 'pbkdf2_sha256$150000$Ov1tb6gUIi3O$C/AVSg8OeHsy3ephx8Mq5uxxkzNzQQwB0PCDeiRIG/w=', NULL, 0, 'flores@19212528', 'Gerardo ', 'Flores Chuan', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19212528'),
(54, 'pbkdf2_sha256$150000$rDvRsLJktt2W$0h7/U+SADWFjQyJUhDFFeK6hAT3jSYISBgk4/xKcGvQ=', NULL, 0, 'burgos@28064764', 'Jacinto ', 'Burgos Cholán', 'null', 0, 1, '0000-00-00 00:00:00.000000', '28064764'),
(55, 'pbkdf2_sha256$150000$WROxMIkRaEqw$HnqHEQXh9NJPHGj+0YlZZvYzCJIKR3jK2+0eterpy30=', NULL, 0, 'alarcon@27926916', 'José Simón ', 'Alarcón Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926916'),
(56, 'pbkdf2_sha256$150000$FnSpslmZPFMb$5RYxRoyWe1hWv5N7MxTUMKsXG9PGOM9n6YztpOG82yM=', NULL, 0, 'rios@27916422', 'Maria Megidia ', 'Ríos Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916422'),
(57, 'pbkdf2_sha256$150000$15AbHCLvpus5$xXJv87YhcUBdf35vM9Mxy6evonx7foBtNXe8bPaRgw4=', NULL, 0, 'castañeda@43314572', 'Denis Berlyn ', 'Castañeda Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43314572'),
(58, 'pbkdf2_sha256$150000$Lo3R6BXKsu4Y$WIVSuP8Cb2lU8sBGanXVVQlJq7qW4uo6vr4nVmYOkMI=', NULL, 0, 'alarcon@27902250', 'Maximino ', 'Alarcón Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27902250'),
(59, 'pbkdf2_sha256$150000$6AlTSJOXGWgG$LBxOjr3iEwLBuV4sHv3pStVsb206BnCWoe2hIc4pM64=', NULL, 0, 'jara@06093479', 'Teodosio ', 'Jara Perez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '06093479'),
(60, 'pbkdf2_sha256$150000$46eZlgqKQKBW$npmYMHN7Vu+JwAxanwVblYF5X+kygfBBHryu3X5X5JQ=', NULL, 0, 'abanto@42623449', 'Santos Fidel ', 'Abanto Carrera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42623449'),
(61, 'pbkdf2_sha256$150000$vbUml9AWxKGL$DNsoho6XSIZAlIvCFeAK8Wv+WtGPRaT3iInGC2lRvfI=', NULL, 0, 'novoa@43546244', 'Renán ', 'Novoa Arlas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43546244'),
(62, 'pbkdf2_sha256$150000$XBqjxcoycJWR$QdXon0jHOj9yMW3biDiKbvW7r8jqpJPgZ9uU9YNyj/k=', NULL, 0, 'cerdan@26626721', 'Asunción ', 'Cerdan Abanto', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26626721'),
(63, 'pbkdf2_sha256$150000$gcOrrtVQun57$ptClRAdvHznlL5wgpZxSMfn5n1ryUgKh7ze+gsMjP90=', NULL, 0, 'arias@44666468', 'José Wilmer ', 'Arias Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44666468'),
(64, 'pbkdf2_sha256$150000$NaUeRY6J8R3Z$jfC65Bgj4ulpWYvnNLBxemuORcuBMPvg2iLJHFDUt34=', NULL, 0, 'fabian@45622883', 'Sirilo Concepción ', 'Fabian Rosas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '45622883'),
(65, 'pbkdf2_sha256$150000$RHprjbXtEkvp$lZmZE8CJeADrIVgi0IB6m6V+uhV6A8BGnmI2nMOHt/E=', NULL, 0, 'briones@06637319', 'Ambrosio Napoleon ', 'Briones Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '06637319'),
(66, 'pbkdf2_sha256$150000$DUdVaAUxE14s$0OZexSVJCz6gEZp5vzUyxXN2NKdbXfplS8DCYyvmbMk=', NULL, 0, 'duran@43509720', 'María Dominica ', 'Duran Ruiz de Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43509720'),
(67, 'pbkdf2_sha256$150000$Sh35doBF8W7U$tehaqJ8RGptgK6i0WXvakqSYz9IvTf7Sj0NBatAee+I=', NULL, 0, 'bejarano@17975614', 'Manuel Jesús ', 'Bejarano Alvarado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17975614'),
(68, 'pbkdf2_sha256$150000$uAatmls6xDKe$XGZT39N6SoTkWzDbuFN+cawtN2SqIPuUBc83Pd2LFhw=', NULL, 0, 'lelva@74600219', 'Angel Antonio ', 'lelva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '74600219'),
(69, 'pbkdf2_sha256$150000$Lyfp5T9q4fME$mHKDJ+b1l/zhj6prmmmCKFV55hDUInPsWJY7VbUpfjc=', NULL, 0, 'leiva@45265774', 'Ana María ', 'leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '45265774'),
(70, 'pbkdf2_sha256$150000$i6Oif7gpdn7D$EyySD/MSjPZ2jypemSELcJIhPgL26Ggnr4l17ZQoPRM=', NULL, 0, 'lelva@43504257', 'Santa Adriana ', 'lelva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43504257'),
(71, 'pbkdf2_sha256$150000$5ArYZm3Xv6FU$M7Cr99HpfrATvjKE1ZS0Iykhhc5gE7aWoGm5x/sLB8c=', NULL, 0, 'leiva@42186924', 'Fabio Sebastian ', 'leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42186924'),
(72, 'pbkdf2_sha256$150000$FIwapIx74Ds3$UZSIdscgJyD/7GRYFchXrHkW30KuVDM9gVXMiiOlTFU=', NULL, 0, 'leiva@40806777', 'Silverio Avelino ', 'leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40806777'),
(73, 'pbkdf2_sha256$150000$Erczhah6Tpp2$ggmn+npDXBHD6xRXQvMr4r/uzPoV/YlMFJuG7mUWVjU=', NULL, 0, 'pelon@4668s803', 'Isollna Concepción', 'Leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46685803'),
(74, 'pbkdf2_sha256$150000$IoKHqa6ierYD$wXGLdy4XMA7mOOxqHRqIWpg9QURq4r8P2SUIJU45/jY=', NULL, 0, 'leiva@47906316', 'Juanita Bautista ', 'Leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47906316'),
(75, 'pbkdf2_sha256$150000$MIloHAbHqGDk$o2/cq1dvo/dIXwrxAMNdUSc6+3m7D0xx6xKoObcWHmU=', NULL, 0, 'rodriguez@26933968', 'Marciano ', 'Rodríguez Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26933968'),
(76, 'pbkdf2_sha256$150000$zhDF3xNbnKCO$lzd7Q4rTQ/ctkeZo/l45BWQUTZWI/MZKQAKRgrIjPN8=', NULL, 0, 'vasquez@10741510', 'Humberto ', 'Vasquez Morales', 'null', 0, 1, '0000-00-00 00:00:00.000000', '10741510'),
(77, 'pbkdf2_sha256$150000$6Mh7Jx4uldOv$t+9P+FYvD9suB+gAT01RZ2yVh8qhlf2L9lfJHRY67AQ=', NULL, 0, 'muñoz@18047708', 'José Andrés ', 'Muñoz Jave', 'null', 0, 1, '0000-00-00 00:00:00.000000', '18047708'),
(78, 'pbkdf2_sha256$150000$w5DijRrTVJP5$4pkFywKIJMg1pzJJ4gxXJV7LXQrG6TyIF0+E1EEguog=', NULL, 0, 'briones@27929924', 'Maritza Emperatriz ', 'Briones Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27929924'),
(79, 'pbkdf2_sha256$150000$Bqyjcaq8kkMp$ERbe1MbXoMgF75FE11X7NkYfXvNDSbGuEBcSXHmQDy4=', NULL, 0, 'quispe@08334338', 'Epifanio Fredy ', 'Quispe López', 'null', 0, 1, '0000-00-00 00:00:00.000000', '08334338'),
(80, 'pbkdf2_sha256$150000$qjFAalSPFZwX$/mgwmR79BR/bKlh6P2BRhPwUmsWvLN1RTONH+LMrqIg=', NULL, 0, 'agullar@27921605', 'Esteban Teofllo ', 'Agullar Chavez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27921605'),
(81, 'pbkdf2_sha256$150000$ZaTJTxhfcfVM$NqUj1vKt6HC2G6xV4/tlKbMAa299es1Gb8zgxlHBUK4=', NULL, 0, 'chavez@07571604', 'Mario Lodorico ', 'Chavez Atildo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '07571604'),
(82, 'pbkdf2_sha256$150000$dq8rfyKAsiAF$Tl5lNkuwlDujKDf1CCkh4t1yi+2twqQmCeSzCGoAj9w=', NULL, 0, 'gonzales@27906685', 'Pedro ', 'Gonzales Carrera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27906685'),
(83, 'pbkdf2_sha256$150000$aPOdd336pmhZ$rRVcpZ8p5UlN+RDHAO0F++N/aQSaLtwxOI6xV7h9ROI=', NULL, 0, 'palomino@19328715', 'Hugo Percy ', 'Palomino Quiroz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19328715'),
(84, 'pbkdf2_sha256$150000$dzDNBUrOfcRi$4D9QQbXjwCDSGvaJQScp/hKaZQjwgT5rnQ1F+JTVyGY=', NULL, 0, 'llanos@33808544', 'Juan ', 'Llanos Barriente', 'null', 0, 1, '0000-00-00 00:00:00.000000', '33808544'),
(85, 'pbkdf2_sha256$150000$PHVBzmcLFzgi$YZXAN0HcepeQuaI7gKj7OZ/6Bvg9HF4JiarxdShQyYI=', NULL, 0, 'abantos@26925262', 'Jaime ', 'Abantos Asaftero', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26925262'),
(86, 'pbkdf2_sha256$150000$6XJtQwHjW2Co$MVmiLMpJqw8vjCny5JXdZrkGT1Sijd2yNW002Kbt46o=', NULL, 0, 'carrera@44032706', 'Lelis Ivan ', 'Carrera Izquierdo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44032706'),
(87, 'pbkdf2_sha256$150000$Q7AtI2CBW01H$79+JOGsyCrBJ5m7V9SGuzAE5rc+t913JO/b/3UcDKso=', NULL, 0, 'honorio@25478809', 'José Benito ', 'Honorio Cruzado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '25478809'),
(88, 'pbkdf2_sha256$150000$X7DF96miWDEJ$iYB23rxhXX8Droi30Dyta5kzCrwOV2Zthio0AO7d1R0=', NULL, 0, 'olortegui@19260043', 'Wilder Roger ', 'Olortegui Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19260043'),
(89, 'pbkdf2_sha256$150000$zRtMdbDO5bvt$S0p2M8F84n2BOZH13JUR0qXub9lL4Ey3jgHoOmvlAYI=', NULL, 0, 'cabanillas@26722350', 'Felix ', 'Cabanillas Villanueva', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26722350'),
(90, 'pbkdf2_sha256$150000$S1w8LF6MsJar$0WP2GKs9p+/QFTyqbtkWYu53b0m5fM9hBDNh1EpSotQ=', NULL, 0, 'lezama@40666289', 'Ludgerio Benigno ', 'Lezama Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40666289'),
(91, 'pbkdf2_sha256$150000$05MqzaQPnOUP$rjYEcjMo/BD6JPA/TqEGBqW30hZrkak7weZPIiEfcVw=', NULL, 0, 'gregorio@27745461', 'Santos ', 'Gregorio Guerrero', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27745461'),
(92, 'pbkdf2_sha256$150000$ymOmwjUYKyYf$rLUqf3vjByUaMrqXDHoG9fnuW2FGEd/26oys05RJtbc=', NULL, 0, 'rojas@27902846', 'Modesto ', 'Rojas Ruiz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27902846'),
(93, 'pbkdf2_sha256$150000$nsB2t2jRiieI$n7iMr7RoxnQZh+rvyB/i+Os0st1HnsAGE0vIrx3CUU8=', NULL, 0, 'quiroz@27910948', 'Víctor Marciano ', 'Quiroz Cruzado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27910948'),
(94, 'pbkdf2_sha256$150000$8P2fmgyHoXzg$Ow0kRrzEgKj9nZVY+RuLE+mM3KanaN7qXvRAm6eUI/M=', NULL, 0, 'cotrina@41957768', 'Robert Franklin ', 'Cotrina Lezama', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41957768'),
(95, 'pbkdf2_sha256$150000$yMs8f671KmzU$Vx7BjntNoMo/L8bZ5XEtYYkeLyxhKUQNy7wxPH52+Ng=', NULL, 0, 'sanchez@46143897', 'Jhonell Jesús ', 'Sánchez Muftoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46143897'),
(96, 'pbkdf2_sha256$150000$K9eTb2t1Xo3d$gCzFAc/Qwjba2u76n3cEVExIu9LErKBa/8tfhdX1ywI=', NULL, 0, 'muiloz@27927921', 'Felix Octavio ', 'Muñoz Pinedo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27927921'),
(97, 'pbkdf2_sha256$150000$s0D0BEeCv0LK$IIc8nM5p3YV9vyCe95TIsbttyszSgo8aN2BA2wpbuL4=', NULL, 0, 'sanchez@44034409', 'Wilder David ', 'Sánchez Paz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44034409'),
(98, 'pbkdf2_sha256$150000$ohrFkbJyI0OF$1UHP6QlCNz0IcRAkGHRArdhnVVO9I5mnMhqEK28QYQQ=', NULL, 0, 'suclupe@47s06740', 'Kevin Raúl ', 'Suclupe Bazan', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47506740'),
(99, 'pbkdf2_sha256$150000$7VvwGHbctzPE$mk4SlZNRwLiFEo5Ng3uciFOGLYSY1b98gKWM1Xl43jw=', NULL, 0, 'sanchez@47519976', 'Jean Carlos ', 'Sánchez Muñoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47519976'),
(100, 'pbkdf2_sha256$150000$qi2tXKJkQnOz$+Tz0gqQHem9kWxN13wj0KxLgeio2n8UCO/h4RsDsnNE=', NULL, 0, 'vasquez@71009442', 'Gabriela Isabel ', 'Vásquez Vásquez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '71009442'),
(101, 'pbkdf2_sha256$150000$siB0o1GG3y35$gh9a/sU14wE10njSwrA5OncF6lmT+X2YkD5juaJVE3E=', NULL, 0, 'calderon@26958782', 'Amella ', 'Calderón Acevedo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26958782'),
(102, 'pbkdf2_sha256$150000$BGfOa4t51hMh$XBc7dERk4F6jiWISUbn7TPxLtnCqx5wUl5yJb8F93Tc=', NULL, 0, 'urbina@27916429', 'José Ignacio ', 'Urbina Huaccha', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916429'),
(103, 'pbkdf2_sha256$150000$O6Y0fV3IsK4F$18TAkLAQ1mIvPWdWuztqSpWoL9EF8XkeT12VrzDcWPY=', NULL, 0, 'torres@44182728', 'Alexander ', 'Torres Jimenez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44182728'),
(104, 'pbkdf2_sha256$150000$l9BhrK7DKq5i$6r5Xei6bMZCwypZrnVTVynyJTotxplOqvO7AZZVYGZw=', NULL, 0, 'yzquierdo@00000000', 'Maria Segunda Juana', 'Yzquierdo Huaman', 'null', 0, 1, '0000-00-00 00:00:00.000000', '00000001'),
(105, 'pbkdf2_sha256$150000$MDrOPa5j0OLe$4xK9NxwCJfm+fb+gGOfnU6xBF30VS/IrSOEigtCHQXk=', NULL, 0, 'sanchez@6251105', 'Alejandro ', 'Sánchez Vera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '06251105'),
(106, 'pbkdf2_sha256$150000$SqCrGYQF3QRF$Al6A40Bn7sLycWhffLPsQHl0yDPn0a0L2fHjJiMpOwE=', NULL, 0, 'sanchez@41157915', 'Joel Aldemar ', 'Sánchez Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41157915'),
(107, 'pbkdf2_sha256$150000$w4P3dtdg6nwD$GTQLDDXfUuH7O23CRi7J1ktd7OVxWmB3XJiWvzfJiSo=', NULL, 0, 'rojas@19331071', 'Segundo David ', 'Rojas Vasquez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19331071'),
(108, 'pbkdf2_sha256$150000$xPwLJ0N59Giy$ZNFODkH7iHNrzgSnuHPgc5WManYfoCdlFyYWL+PCEug=', NULL, 0, 'muñoz@19328773', 'Felicitas', 'Muñoz Pinedo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19328773'),
(109, 'pbkdf2_sha256$150000$ir5Vqlv6DN5j$Er1PHWu0XuiLue7N3SIGBVY9Nw9/nCrfwMpeRPiPmLs=', NULL, 0, 'lezama@1815f676', 'Marta Asunción ', 'Lezama Mendoza', 'null', 0, 1, '0000-00-00 00:00:00.000000', '18158676'),
(110, 'pbkdf2_sha256$150000$F4ZgEgEgTGpO$0kQbdl1bX9ybIZInLeCsCSdJ5uag9ION76shX9bpT7o=', NULL, 0, 'tirado@19328782', 'Caytano ', 'Tirado Durand', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19328782'),
(111, 'pbkdf2_sha256$150000$42nyOtlDgA4w$HonhhTeWfgKMeM17PSA9ccA4sNtLqUmYYSesq7Za9Vw=', NULL, 0, 'gutierrez@40869212', 'Manira Lisette ', 'Gutierrez Rivasplata', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40869212'),
(112, 'pbkdf2_sha256$150000$cFfPgmajEeKH$o+8AFsp/yU45jvwzEWWd1/xUZ4RkYOeQZmk/5N3vFkQ=', NULL, 0, 'gutierrez@70524730', 'Valeria ', 'Gutierrez Rivasplata', 'null', 0, 1, '0000-00-00 00:00:00.000000', '70524730'),
(113, 'pbkdf2_sha256$150000$aPlqeyOM9BfM$XMtMmAc0JCXNR8VlkvS0R1IpdeNzCuNfJlBhgj6L2Jg=', NULL, 0, 'gutierrez@08187055', 'Jorge Amado ', 'Gutierrez Esaine', 'null', 0, 1, '0000-00-00 00:00:00.000000', '08187055'),
(114, 'pbkdf2_sha256$150000$rhtJkNTJgN5H$ZtT2tAxTBUUXlFJYZ+pmPJqI79oQ/EDC1GIpvgz/Abw=', NULL, 0, 'cotrina@42965616', 'Christian Javier ', 'Cotrina Lezama', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42965616'),
(115, 'pbkdf2_sha256$150000$xVuLMbetgoKU$ODtykzsbywXK2VWl2qZuVNUlXVv2DIYa0dSA9XVegh0=', NULL, 0, 'deza@41907802', 'Lucia Pastora ', 'Deza Rodríguez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41907802'),
(116, 'pbkdf2_sha256$150000$eCRtLRypoFkZ$XF+AAnVk9aVLL7NzG9dZha0JZD9BQOhFZLCHFG201zU=', NULL, 0, 'sanchez@27911329', 'Corpus Mercedes ', 'Sánchez Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911329'),
(117, 'pbkdf2_sha256$150000$dYzvfcdZaM26$5Yme5CPHks9hnwgnLHJpn0jd5s1X26aSgdFbszKfvH8=', NULL, 0, 'castañeda@40353504', 'Henry Wllfredo ', 'Castañeda Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40353504'),
(118, 'pbkdf2_sha256$150000$l5AnvIQywnNi$eQAlHj5L4yniFQcaR83OyhCMCMSjyv1j9W3fP8BwTSU=', NULL, 0, 'castañeda@27911328', 'Segundo Wllfredo ', 'Castañeda Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911328'),
(119, 'pbkdf2_sha256$150000$iwfGYbPuZmii$rBzpexRFo4d+DRah8/RAo4JA4JgJUtD5kox48f0ZKXc=', NULL, 0, 'valderrama@27916045', 'José Elíseo ', 'Valderrama Vargas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916045'),
(120, 'pbkdf2_sha256$150000$q2AeRiBeYufR$DFTFRKzE5K9bGFCf/RTTjR9amtD7cxTCCnsG+9yXs+A=', NULL, 0, 'alias@26667183', 'José Melquíades ', 'Alias Pastor', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26667183'),
(121, 'pbkdf2_sha256$150000$DsUf5iUADyYu$rAGjyMG6c9uSbsC7v4zWJ/PLr+dMuoXra7jWABN0zaM=', NULL, 0, 'medina@18866339', 'Maria Esperanza ', 'Medina Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '18866339'),
(122, 'pbkdf2_sha256$150000$4MyQ6kmB1x3j$7XBGRPbQt8IqP2E9pJsA3WJDVEWq/KfZ8jTE/N2hMlI=', NULL, 0, 'paredes@42772161', 'Francisco Apolinar ', 'Paredes Medina', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42772161'),
(123, 'pbkdf2_sha256$150000$oyo0XS89KqzM$iM2mIbY/lEN5NxpeK9yU7c5wv9rmytgoPR1fjijJtGA=', NULL, 0, 'muñoz@26667585', 'Diomedes ', 'Muñoz Machuca', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26667585'),
(124, 'pbkdf2_sha256$150000$45Gsa4oQN9wt$u4JJaYD/RkmtWeDLWjE129VodV+ZNJG69BA7XSfBbkc=', NULL, 0, 'vargas@27901888', 'Domiclano ', 'Vargas Burgos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27901888'),
(125, 'pbkdf2_sha256$150000$nV4vFTXNi3VM$hHr7sFgKBtkfRz8qEFDzm7tGxSRZYBzqImehkOroUgA=', NULL, 0, 'rabanal@27910890', 'Manuel Valentin ', 'Rabanal Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27910890'),
(126, 'pbkdf2_sha256$150000$IUgYZCeGpFfO$e6wPjzjeL7nxFyvx4VZAUvc4jWVVpIasl/c+RnL+LwE=', NULL, 0, 'tirado@26625797', 'José Quirino ', 'Tirado Urbina', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26625797'),
(127, 'pbkdf2_sha256$150000$BLXCDQOr5iT4$Yb9w4oYoo+GJa8+rp3GuTWaiRjMfPLDkimqtFJjjLe8=', NULL, 0, 'tirado@43218123', 'José Luis ', 'Tirado Ríos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43218123'),
(128, 'pbkdf2_sha256$150000$lu0wtbZIkRBj$ioNNiJL2IzaBVBnqyRaHSGLNxlK3DnFnb0pVsbnDUGA=', NULL, 0, 'jara@43476300', 'Ernesto', 'Jara Choroco', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43476300'),
(129, 'pbkdf2_sha256$150000$hB3hvw0buosl$8fhNM85o5at8Q0c9t3hpsxoKytGaCbh0sziXEt8JP5g=', NULL, 0, 'culqui@43497168', 'Rubén Leonardo ', 'Culqui Chunqui', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43497168'),
(130, 'pbkdf2_sha256$150000$eJU6cnYDDRsL$YDNh4Wk1kYZXC217ftNSthEHFqdTyXK3x2Nv1ly9Y+A=', NULL, 0, 'rabines@41917146', 'Pedro Miguel ', 'Rabines Olortegui', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41917146'),
(131, 'pbkdf2_sha256$150000$gBtyd5fCHoqF$8yn8EJhI8X1XRwihuKvZ3aJeeR5zwV9v0oQlGDatFJA=', NULL, 0, 'castañeda@19320491', 'Dora Alvina ', 'Castañeda Suarez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19320491'),
(132, 'pbkdf2_sha256$150000$sEKFST0I83wA$Yom79r2RDOs3b8OQK+8ssmA4zw3YWRTfj/xSvFKHfQg=', NULL, 0, 'linares@44791210', 'Alan Rodin ', 'Linares Mendoza', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44791210'),
(133, 'pbkdf2_sha256$150000$Axv0KJvJK4xT$Mi1aLA+WTXwbaTznbJvbV1CPQnHbGD7sTGuBLQVY/AM=', NULL, 0, 'la@44306833', 'Juan de ', 'la Cruz Ramírez Bueno', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44306833'),
(134, 'pbkdf2_sha256$150000$kpSZlZLcbK9M$5hZyMa11goSOBmdrvm3gGrZEJgsNnLYpzOJjKE0wMJA=', NULL, 0, 'pastor@27926202', 'Agustín ', 'Pastor Abanto', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926202'),
(135, 'pbkdf2_sha256$150000$B1P64jaTglqq$Zn72sne5i+rZhhbddqIdGnt1jMs5bys7b+U/Lf6Mh3U=', NULL, 0, 'cotrina@40252939', 'Segundo Raúl ', 'Cotrina Olortegui', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40252939'),
(136, 'pbkdf2_sha256$150000$jxcPIZlbeKar$a17Im3xLrvXOOGZ3MOm+2tkjk80uX83BgYP6QDs6dL0=', NULL, 0, 'moreno@26923105', 'Sixto Doroteo ', 'Moreno Avalos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26923105'),
(137, 'pbkdf2_sha256$150000$M3Pno905yMzd$VbIhjaJGq/2F9vACSQ8RnI/7OgCM58DhXlEMfpXeh/4=', NULL, 0, 'abanto@17910919', 'José Germán ', 'Abanto Crespin', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17910919'),
(138, 'pbkdf2_sha256$150000$JUmDRemUfrUq$MtnR/CZGi9pGryfrOC9XD84mqoIOtRX5iQibjZVODik=', NULL, 0, 'rojas@27901015', 'Quiteria Elena ', 'Rojas de Briones', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27901015'),
(139, 'pbkdf2_sha256$150000$LFLdwMAzVEpE$1B58iGoFtPhl9b+CTaoU+wwgi102yHLGJnNNNI7KKx0=', NULL, 0, 'cieza@00000000', 'Mara Jazmin ', 'Cieza Briones', 'null', 0, 1, '0000-00-00 00:00:00.000000', '00000002'),
(140, 'pbkdf2_sha256$150000$njKm1LwoHdFy$2XkMLDlC6cD/rgAckMwZSReotG6lVrwYXPFWBnIA83M=', NULL, 0, 'paz@19216567', 'María Beldad ', 'Paz Cruzado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19216567'),
(141, 'pbkdf2_sha256$150000$2wPUozUNLm0Z$r0wCUHtDZVzBV/ve4rBPCzmVaoA6nhsyoX85j5Ipfv8=', NULL, 0, 'morales@44089836', 'Wilmer ', 'Morales Arrelucea', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44089836'),
(142, 'pbkdf2_sha256$150000$CDobvSjALi2C$FSeVDA8BlXIjagLB+QJn19j+qJKkD2TJ3eR2P/HqvdU=', NULL, 0, 'ruiz@27911005', 'Segundo ', 'Ruiz Meléndez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911005'),
(143, 'pbkdf2_sha256$150000$KzcMi6TaNU8C$2qt8OVonmuY103dlL9Xlr6jAhOH5wA1wFK5mVSIC+CM=', NULL, 0, 'mejia@43015053', 'César Danny ', 'Mejía Vásquez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43015053'),
(144, 'pbkdf2_sha256$150000$boFBwZd8hwI8$StuGzSR3mfIcX8akQDwXuozkOkOr2JVRzDnEF2Thj1w=', NULL, 0, 'garda@47256724', 'Agustín ', 'Garda Jara', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47256724'),
(145, 'pbkdf2_sha256$150000$WaWfdwutEMlb$PujhlY8Qh5ozheUzrSBZRB4lrS+IGLKvrR+fPre11YY=', NULL, 0, 'flores@26701199', 'Luis ', 'Flores Chuquiruna', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26701199'),
(146, 'pbkdf2_sha256$150000$7tes7mBmqxrh$Rp/q4b9m2gWkXpKPk3xvaHtEogQoSDdgbUohh/3v4vo=', NULL, 0, 'rabanal@26699572', 'Primitivo ', 'Rabanal Guerra', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26699572'),
(147, 'pbkdf2_sha256$150000$IjANKuN4Ka2H$zKYmaHHjtkPmJtA5+RHqcQACz2llWZ6UKHUdeGWC7cg=', NULL, 0, 'cerdan@41429546', 'José Cruz ', 'Cerdán Ríos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41429546'),
(148, 'pbkdf2_sha256$150000$vLanbYa4eQ4m$01cf/ZGAExMzvP6xU1BKshRNm7PgKxzdw4jYKgdPtac=', NULL, 0, 'novoa@42929678', 'Leoncio ', 'Novoa Arias', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42929678'),
(149, 'pbkdf2_sha256$150000$VSRLwhN6w88y$r3ZiNodTI6MrHVkRHuiMRS9v/bp+7jB+Xf5xdYtn4wE=', NULL, 0, 'tirado@43821528', 'Rosendo ', 'Tirado Medrano', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43821528'),
(150, 'pbkdf2_sha256$150000$hSEV1BOA8bUp$ODrVrWXrVpuApcZPsgUJYXB7XgIzR1HQtV3ONvf3DBk=', NULL, 0, 'arias@45377324', 'Bladimir Ernerzon ', 'Arias Machuca', 'null', 0, 1, '0000-00-00 00:00:00.000000', '45377324'),
(151, 'pbkdf2_sha256$150000$qfP5lwFbi6E7$mjsuYCU/EhEEIzLCyQOJMpwJ6MID/vK0sbVodMi46Jk=', NULL, 0, 'rios@27926996', 'Elias ', 'Ríos Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926996'),
(152, 'pbkdf2_sha256$150000$WgM6jxF2JtQn$wnuRrSRXyTF4z8I5X4oEvFEzMsBEV6WVNApWKsJdgOc=', NULL, 0, 'novoa@46970061', 'José Demerio ', 'Novoa Arias', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46970061'),
(153, 'pbkdf2_sha256$150000$NmAyn1Mp5B22$ha1/m+xwx9e7BadxGcnB4BeYGLKLvAEsO26BdG2QQfg=', NULL, 0, 'sanchez@10477468', 'José Luis ', 'Sánchez Licera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '10477468'),
(154, 'pbkdf2_sha256$150000$UkOhI5MCX6O1$s/Gx/JYE6VZCaBn8lWq0FxMImI0pXPA/erdE1ievGgs=', NULL, 0, 'castañeda@27905888', 'Rosel ', 'Castañeda Valera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27905888'),
(155, 'pbkdf2_sha256$150000$pieUXc5ZFAMi$AQYZOXfJdUFq8dTy1lL/M8Fn0x3nVvSS/gFLmOIRV0k=', NULL, 0, 'silva@42877693', 'Abel ', 'Silva Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42877693'),
(156, 'pbkdf2_sha256$150000$8eGujdJ2S0iR$HCkScJuShhXKb20HYMuoxeB/AkFRenlnGQhONxcnYyM=', NULL, 0, 'abanto@44406126', 'Ingrid Smith ', 'Abanto Becerra', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44406126'),
(157, 'pbkdf2_sha256$150000$PNOed50UxeXV$9o9+Bc8hmRu1o6AQIbrdcOAxaxnfmX22Y5TR9W+Aw9w=', NULL, 0, 'marin@27926267', 'Napoleon ', 'Marán Dávila', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926267'),
(158, 'pbkdf2_sha256$150000$lk7z8EMu6bXi$tNlXIMH1xNl2H2XRdTYIHmHMMxo+v3NgfB0BqYo8qAA=', NULL, 0, 'cabrera@27903180', 'José Juan ', 'Cabrera Quiroz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27903180'),
(159, 'pbkdf2_sha256$150000$H5DGiePtc86E$tq0agPeKB+usSTVkUTokY6VQNHz6PdKmBtC/gd4HC4A=', NULL, 0, 'zare@17887991', 'Rosa Mercedes ', 'Zare Reyes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17887991'),
(160, 'pbkdf2_sha256$150000$2498GcWpkhxA$k60Kpe4JG8+ym2L3yrtGJjgkd8iU5aCBUJ6kbPKjUS4=', NULL, 0, 'sanchez@00000000', 'José Miguel ', 'Sánchez Perez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '00000003'),
(161, 'pbkdf2_sha256$150000$4EwmEWkyZgbD$hB70+5zwg26VzQFRpII+QL6PUP9FEbcRqEt1Eb4VzXA=', NULL, 0, 'castañeda@19201895', 'Gonzalo ', 'Castañeda Suarez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19201895'),
(162, 'pbkdf2_sha256$150000$6i0IhFi1dNik$s0biswrt0UxHk+ZJuweYnua1XozFWMuAKdZAtpok9iY=', NULL, 0, 'barrantes@26926326', 'Adrián ', 'Barrantes Blas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26926326'),
(165, 'pbkdf2_sha256$150000$M9IGbkKTj06f$NwclJxxcUGRcM0WUtozlo2SyK4naGIHOR1BTKVkYSIY=', NULL, 0, 'melendez@27911205', 'Pedro Agapito ', 'Melendez Gonzales', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911205'),
(166, 'pbkdf2_sha256$150000$DuTllNtNdvMR$HVqxaHXge3qnSIdyW3KJmRegcWCy4ZbhvHq1TefRpnE=', NULL, 0, 'quiroz@27920687', 'José Ceferino ', 'Quiroz Huaman', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27920687'),
(167, 'pbkdf2_sha256$150000$9EL5qD95fEQd$dckMs12UlZs3T0Kv3ivwtOkQEYHOou7bfUSIquIRLYk=', NULL, 0, 'marin@27913517', 'Eusebia Maruja ', 'Marán Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27913517'),
(168, 'pbkdf2_sha256$150000$e354tMhSWtat$bXc+Dv2RejAf7qAUMKosn+q4tNxWFipO2Ud4TrASS0I=', NULL, 0, 'castañeda@45717942', 'María Delisbeth ', 'Castañeda Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '45717942'),
(169, 'pbkdf2_sha256$150000$tx0TLr8qmvqv$qY2mWkJs11XF1IIV+UtigM4Eq8h0ZjqEQ9WiVmJsaCM=', NULL, 0, 'carrera@42807858', 'Santos Elmer ', 'Carrera Izquierdo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42807858'),
(170, 'pbkdf2_sha256$150000$3nca6ln5A2uW$uuAFJpB9v4+8WCb5/ezpmiLIHIn2JZuC5DB3l33FtTE=', NULL, 0, 'medina@27913458', 'Sara Mercedes ', 'Medina de Aguilar', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27913458'),
(171, 'pbkdf2_sha256$150000$CX0ZePHKsGie$21sCqCjisG6GBLieWpCIM7h9nSsJh4US/iwiw3TqQpA=', NULL, 0, 'sanchez@27901910', 'José Alejandro ', 'Sánchez Torres', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27901910'),
(172, 'pbkdf2_sha256$150000$yyt11mFXjlpu$fevMR6yT8bqYlgAyWUHpkbOg1wkEKotfBAYNoLpUmJI=', NULL, 0, 'rojas@27926927', 'José Jesús ', 'Rojas Tirado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926927'),
(173, 'pbkdf2_sha256$150000$XSSU3eo4NsDL$lEqvjK/iBoiMvqw5RyH4mJSKBfKXsbCs3gXKz+j8qGQ=', NULL, 0, 'tirado@41212545', 'Maria Eulalia ', 'Tirado Muñoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41212545'),
(174, 'pbkdf2_sha256$150000$QVLlZlKAjMlc$x18gMnda3b6WOMe2d4mndvQcAM/x4S0AUoEdnzBkGgM=', NULL, 0, 'cabanlllas@27927033', 'José Arcadio ', 'Cabanlllas Moreno', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27927033'),
(175, 'pbkdf2_sha256$150000$vD0c9w9F0TYP$D8rfRqDge1HXTImMcxJcTBC6otcCy7ooegjxE7DrABo=', NULL, 0, 'sanchez@27929210', 'Santos Percy ', 'Sánchez Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27929210'),
(176, 'pbkdf2_sha256$150000$w3qkbeWdk1Sp$NKjfuxng7Wo06+UTAG2KItsWPP4mTPiShqcaHBX9JDs=', NULL, 0, 'valera@25441298', 'María Lidia ', 'Valera Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '25441298'),
(177, 'pbkdf2_sha256$150000$rB3lNPlyERgo$I+g1xwGhTwWxODxMZSDKyjO05xY8m71iHZUPFLGf4FI=', NULL, 0, 'vasquez@42968280', 'Yencarlos ', 'Vásquez Delgado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42968280'),
(178, 'pbkdf2_sha256$150000$g2C5JWdiEVTF$6Cwe525AR6iLMalM7yaVWhSB6g/6T1foRCpd8dIfSXg=', NULL, 0, 'tirado@46554129', 'Diomelis ', 'Tirado Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46554129'),
(179, 'pbkdf2_sha256$150000$moqF7Ff03XxB$CyTiu1u5BYimNuRgpzQa6302XREA5w0KQg39MOiBBBc=', NULL, 0, 'eugenio@19205161', 'Luda ', 'Eugenio Tocas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19205161'),
(180, 'pbkdf2_sha256$150000$pcrJesX6Dt7g$xUlhLd6+rldTPQ8tlWYO20BUAJ5yG4mcKKW9LajDfXs=', NULL, 0, 'machuca@27904785', 'Florentino ', 'Machuca Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27904785'),
(181, 'pbkdf2_sha256$150000$dGYUTHQ8tNd8$gSZvJ3PBdE1uWYPdSQHoo8mjyR/1Fbtjo0o55BbHRgM=', NULL, 0, 'lezama@27913696', 'José María ', 'Lezama Mendoza', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27913696'),
(182, 'pbkdf2_sha256$150000$ytzyvP45fONg$yEetyPa7chEJS0KwqyD4rl2Jz85BwC/zOFvC/rJTwJg=', NULL, 0, 'ayay@19240928', 'Felipe Pascual ', 'Ayay Carrasco', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19240928'),
(183, 'pbkdf2_sha256$150000$R2ciQhLsSpIg$PO8Y+Ah/1ST3GPgjQpgZvbuDD9FPNub7sPOPZbP5vUY=', NULL, 0, 'izquierdo@00000000', 'Maria Santana ', 'Izquierdo Velezmoro', 'null', 0, 1, '0000-00-00 00:00:00.000000', '00000006'),
(184, 'pbkdf2_sha256$150000$96NySVFdO0m7$CGgxGnDZE3TFntJA8ctPYVroYDZTSC6ArIXTK8HCvJk=', NULL, 0, 'quipe@41711178', 'Santiago ', 'QuispeTello', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41711178'),
(185, 'pbkdf2_sha256$150000$mg5FFqao6Gou$p5dMLR91ehKMYhGA5SE9PxnxzrkbnkKkB1fi/WA68+o=', NULL, 0, 'flores@74357312', 'José Ivan ', 'Flores Abanto', 'null', 0, 1, '0000-00-00 00:00:00.000000', '74357312'),
(186, 'pbkdf2_sha256$150000$ajKUpwtS9Xfs$RWwjhfzub0ZXra2J5vcCRFqzcoT3v/8AVJlU0dpr1QE=', NULL, 0, 'arias@43722068', 'Ludim Melquesidec ', 'Arias Machuca', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43722068'),
(187, 'pbkdf2_sha256$150000$wDpu52wjOOfc$gEPyEmGS0pGXksUwUgEYFZmIvtH2YhH3tjeC1qhQKec=', NULL, 0, 'abanto@80038061', 'Maria Mercedes ', 'Abanto Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '80038061'),
(188, 'pbkdf2_sha256$150000$QVtNmtQaBBVI$Ao2ZKWs1CPni274rWQohoXC4fAyf1BevWWv0xAqPT6A=', NULL, 0, 'muñoz@40391027', 'Felicita Guísela ', 'Muñoz Machuca', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40391027'),
(189, 'pbkdf2_sha256$150000$KyxNaGEndXyC$exmtRoV84RKyOUrcFmFDX1wCl+qzuiNY4h8rMovVn/o=', NULL, 0, 'rios@41697257', 'Maximiliano ', 'Rios Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41697257'),
(190, 'pbkdf2_sha256$150000$uPobyhFKFDzt$a37/DdvnuPyN4HLf44urTzkNvgw0VgUunYE4/Kt0hNU=', NULL, 0, 'karin@46743454', 'Pamela Yovanna ', 'Karin Muñoz Soto', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46743454'),
(191, 'pbkdf2_sha256$150000$moxs1TTUPFZe$Qkbg4y7YK44KMJ9bCQgq0n8JTDIOkVP6IqjFOkVo5Pw=', NULL, 0, 'becerra@19332504', 'José', 'Becerra Beyodas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19332504'),
(192, 'pbkdf2_sha256$150000$1aWOcnYlUVrf$lRpnIaLOIC7LnWS4T45GPD3MP80VvQc+UIyMDWUQjs4=', NULL, 0, 'galarreta@26922504', 'Américo Inocente ', 'Galarreta Quesada', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26922504'),
(193, 'pbkdf2_sha256$150000$VDSG4jpWz3u5$EkrGf1XOmTc0PAUvJUYnAfuQZwb69t+rS8M/jLOht6Q=', NULL, 0, 'novoa@46546249', 'Renán ', 'Novoa Arias', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46546249'),
(194, 'pbkdf2_sha256$150000$H0jjqJtwa5wW$2sglJhCUEd2tnsZdk7Qo3Ad0BCeVRnbHrRO3OP5H40E=', NULL, 0, 'honorio@40633699', 'Juan Robert ', 'Honorio Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40633699');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_groups`
--

CREATE TABLE `auth_user_groups` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_user_permissions`
--

CREATE TABLE `auth_user_user_permissions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `auth_user_user_permissions`
--

INSERT INTO `auth_user_user_permissions` (`id`, `user_id`, `permission_id`) VALUES
(2, 2, 137),
(1, 3, 138);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `canal`
--

CREATE TABLE `canal` (
  `id_canal` int(11) NOT NULL,
  `nombre` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `tamano` double DEFAULT NULL,
  `ubicacion` varchar(45) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `canal`
--

INSERT INTO `canal` (`id_canal`, `nombre`, `tamano`, `ubicacion`) VALUES
(1, 'Ramal 1', 5035, 'Canal Madre'),
(2, 'Ramal 2', 2526, 'Continuación del canal madre'),
(3, 'Ramal 3', 1104, 'Canal Madre'),
(4, 'Ramal 4', 984, 'parte del ramal 3'),
(5, 'Ramal 5', 1491, 'parte del ramal 3');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caudal`
--

CREATE TABLE `caudal` (
  `id_caudal` int(11) NOT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `nivel` int(11) DEFAULT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `caudal`
--

INSERT INTO `caudal` (`id_caudal`, `id_canal`, `fecha`, `nivel`, `descripcion`) VALUES
(1, 1, '2019-08-01 00:00:00', 6, 'Descripción'),
(2, 2, '2019-08-01 00:00:00', 3, 'Descripción'),
(3, 3, '2019-08-01 00:00:00', 4, 'Descripción'),
(4, 4, '2019-08-01 00:00:00', 1, 'Descripción'),
(5, 5, '2019-08-01 00:00:00', 1, 'Descripción'),
(6, 1, '2019-08-02 00:00:00', 5, 'Descripción'),
(7, 2, '2019-08-02 00:00:00', 2, 'Descripción'),
(8, 3, '2019-08-02 00:00:00', 5, 'Descripción'),
(9, 4, '2019-08-02 00:00:00', 4, 'Descripción'),
(10, 5, '2019-08-02 00:00:00', 5, 'Descripción');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comite`
--

CREATE TABLE `comite` (
  `id_comite` int(11) NOT NULL,
  `nombre` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `descripcion` varchar(200) COLLATE hp8_bin DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comprobante`
--

CREATE TABLE `comprobante` (
  `id_comprobante` int(11) NOT NULL,
  `id_talonario` int(11) NOT NULL,
  `ticket_numero` int(11) DEFAULT NULL,
  `concepto` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `monto` double DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comp_multa`
--

CREATE TABLE `comp_multa` (
  `id_comp_multa` int(11) NOT NULL,
  `id_comprobante` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comp_orden`
--

CREATE TABLE `comp_orden` (
  `id_comp_orden` int(11) NOT NULL,
  `id_comprobante` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos_personales`
--

CREATE TABLE `datos_personales` (
  `id_datos_personales` int(11) NOT NULL,
  `dni` char(8) COLLATE hp8_bin DEFAULT NULL,
  `alias` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `sexo` char(1) COLLATE hp8_bin DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `telefono` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `celular` char(13) COLLATE hp8_bin DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `id_auth_user` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `datos_personales`
--

INSERT INTO `datos_personales` (`id_datos_personales`, `dni`, `alias`, `sexo`, `fecha_nacimiento`, `telefono`, `celular`, `foto`, `id_auth_user`) VALUES
(1, '76583884', 'Nene', 'M', '1994-11-30', NULL, '927088981', 'photos/20180508_165334.jpg', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `destajo`
--

CREATE TABLE `destajo` (
  `id_destajo` int(11) NOT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `id_parcela` int(11) DEFAULT NULL,
  `tamano` double DEFAULT NULL,
  `num_orden` int(11) DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `estado` varchar(1) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `destajo`
--

INSERT INTO `destajo` (`id_destajo`, `id_canal`, `id_parcela`, `tamano`, `num_orden`, `fecha_registro`, `descripcion`, `estado`) VALUES
(1, 1, 1, 15, 1, '2019-05-01', 'Habilitado', '1'),
(2, 1, 2, 8.1, 2, '2019-05-01', 'Habilitado', '1'),
(3, 1, 3, 6.6, 3, '2019-05-01', 'Habilitado', '1'),
(4, 1, 4, 54.9, 4, '2019-05-01', 'Habilitado', '1'),
(5, 1, 5, 26.25, 5, '2019-05-01', 'Habilitado', '1'),
(6, 1, 6, 18.6, 6, '2019-05-01', 'Habilitado', '1'),
(7, 1, 7, 15, 7, '2019-05-01', 'Habilitado', '1'),
(8, 1, 8, 31.65, 8, '2019-05-01', 'Habilitado', '1'),
(9, 1, 9, 13.8, 9, '2019-05-01', 'Habilitado', '1'),
(10, 1, 10, 7.5, 10, '2019-05-01', 'Habilitado', '1'),
(11, 1, 11, 19.8, 11, '2019-05-01', 'Habilitado', '1'),
(12, 1, 12, 14.85, 12, '2019-05-01', 'Habilitado', '1'),
(13, 1, 13, 13.05, 13, '2019-05-01', 'Habilitado', '1'),
(14, 1, 14, 10.2, 14, '2019-05-01', 'Habilitado', '1'),
(15, 1, 15, 15, 15, '2019-05-01', 'Habilitado', '1'),
(16, 1, 16, 39.45, 16, '2019-05-01', 'Habilitado', '1'),
(17, 1, 17, 36.6, 17, '2019-05-01', 'Habilitado', '1'),
(18, 1, 18, 12.15, 18, '2019-05-01', 'Habilitado', '1'),
(19, 1, 19, 14.85, 19, '2019-05-01', 'Habilitado', '1'),
(20, 1, 20, 14.7, 20, '2019-05-01', 'Habilitado', '1'),
(21, 1, 21, 15, 21, '2019-05-01', 'Habilitado', '1'),
(22, 1, 22, 15, 22, '2019-05-01', 'Habilitado', '1'),
(23, 1, 23, 15.45, 23, '2019-05-01', 'Habilitado', '1'),
(24, 1, 24, 15.75, 24, '2019-05-01', 'Habilitado', '1'),
(25, 1, 25, 14.85, 25, '2019-05-01', 'Habilitado', '1'),
(26, 1, 26, 12.9, 26, '2019-05-01', 'Habilitado', '1'),
(27, 1, 27, 15.15, 27, '2019-05-01', 'Habilitado', '1'),
(28, 1, 28, 29.1, 28, '2019-05-01', 'Habilitado', '1'),
(29, 1, 29, 14.4, 29, '2019-05-01', 'Habilitado', '1'),
(30, 1, 30, 14.1, 30, '2019-05-01', 'Habilitado', '1'),
(31, 1, 31, 15.3, 31, '2019-05-01', 'Habilitado', '1'),
(32, 1, 32, 13.35, 32, '2019-05-01', 'Habilitado', '1'),
(33, 1, 33, 60, 33, '2019-05-01', 'Habilitado', '1'),
(34, 1, 34, 30, 34, '2019-05-01', 'Habilitado', '1'),
(35, 1, 35, 38.7, 35, '2019-05-01', 'Habilitado', '1'),
(36, 1, 36, 14.55, 36, '2019-05-01', 'Habilitado', '1'),
(37, 1, 37, 17.25, 37, '2019-05-01', 'Habilitado', '1'),
(38, 1, 38, 17.55, 38, '2019-05-01', 'Habilitado', '1'),
(39, 1, 39, 9, 39, '2019-05-01', 'Habilitado', '1'),
(40, 1, 40, 19.05, 40, '2019-05-01', 'Habilitado', '1'),
(41, 1, 41, 14.1, 41, '2019-05-01', 'Habilitado', '1'),
(42, 1, 42, 12.82, 42, '2019-05-01', 'Habilitado', '1'),
(43, 1, 43, 12.82, 43, '2019-05-01', 'Habilitado', '1'),
(44, 1, 44, 16.03, 44, '2019-05-01', 'Habilitado', '1'),
(45, 1, 45, 26.15, 45, '2019-05-01', 'Habilitado', '1'),
(46, 1, 46, 15.9, 46, '2019-05-01', 'Habilitado', '1'),
(47, 1, 47, 25, 47, '2019-05-01', 'Habilitado', '1'),
(48, 1, 48, 40.9, 48, '2019-05-01', 'Habilitado', '1'),
(49, 1, 49, 11.92, 49, '2019-05-01', 'Habilitado', '1'),
(50, 1, 50, 12.18, 50, '2019-05-01', 'Habilitado', '1'),
(51, 1, 51, 13.46, 51, '2019-05-01', 'Habilitado', '1'),
(52, 1, 52, 13.2, 52, '2019-05-01', 'Habilitado', '1'),
(53, 1, 53, 51.28, 53, '2019-05-01', 'Habilitado', '1'),
(54, 1, 54, 12.56, 54, '2019-05-01', 'Habilitado', '1'),
(55, 1, 55, 16.28, 55, '2019-05-01', 'Habilitado', '1'),
(56, 1, 56, 11.67, 56, '2019-05-01', 'Habilitado', '1'),
(57, 1, 57, 62.05, 57, '2019-05-01', 'Habilitado', '1'),
(58, 1, 58, 51.28, 58, '2019-05-01', 'Habilitado', '1'),
(59, 1, 59, 35, 59, '2019-05-01', 'Habilitado', '1'),
(60, 1, 60, 36.15, 60, '2019-05-01', 'Habilitado', '1'),
(61, 1, 61, 13.08, 61, '2019-05-01', 'Habilitado', '1'),
(62, 1, 62, 11.54, 62, '2019-05-01', 'Habilitado', '1'),
(63, 1, 63, 15.77, 63, '2019-05-01', 'Habilitado', '1'),
(64, 1, 64, 29.1, 64, '2019-05-01', 'Habilitado', '1'),
(65, 1, 65, 62.56, 65, '2019-05-01', 'Habilitado', '1'),
(66, 1, 66, 66.02, 66, '2019-05-01', 'Habilitado', '1'),
(67, 1, 67, 26.41, 67, '2019-05-01', 'Habilitado', '1'),
(68, 1, 68, 39.23, 68, '2019-05-01', 'Habilitado', '1'),
(69, 1, 69, 64.1, 69, '2019-05-01', 'Habilitado', '1'),
(70, 1, 70, 65, 70, '2019-05-01', 'Habilitado', '1'),
(71, 1, 71, 13.85, 71, '2019-05-01', 'Habilitado', '1'),
(72, 1, 72, 49.23, 72, '2019-05-01', 'Habilitado', '1'),
(73, 1, 73, 20.51, 73, '2019-05-01', 'Habilitado', '1'),
(74, 1, 74, 105.12, 74, '2019-05-01', 'Habilitado', '1'),
(75, 1, 75, 22.18, 75, '2019-05-01', 'Habilitado', '1'),
(76, 1, 76, 19.74, 76, '2019-05-01', 'Habilitado', '1'),
(77, 1, 77, 18.08, 77, '2019-05-01', 'Habilitado', '1'),
(78, 1, 78, 6.67, 78, '2019-05-01', 'Habilitado', '1'),
(79, 1, 79, 18.85, 79, '2019-05-01', 'Habilitado', '1'),
(80, 1, 80, 19.23, 80, '2019-05-01', 'Habilitado', '1'),
(81, 1, 81, 21.54, 81, '2019-05-01', 'Habilitado', '1'),
(82, 1, 82, 21.15, 82, '2019-05-01', 'Habilitado', '1'),
(83, 1, 83, 51.02, 83, '2019-05-01', 'Habilitado', '1'),
(84, 1, 84, 64.1, 84, '2019-05-01', 'Habilitado', '1'),
(85, 1, 85, 73.84, 85, '2019-05-01', 'Habilitado', '1'),
(86, 1, 86, 57.43, 86, '2019-05-01', 'Habilitado', '1'),
(87, 1, 87, 51.28, 87, '2019-05-01', 'Habilitado', '1'),
(88, 1, 88, 63.84, 88, '2019-05-01', 'Habilitado', '1'),
(89, 1, 89, 65.77, 89, '2019-05-01', 'Habilitado', '1'),
(90, 1, 90, 63.33, 90, '2019-05-01', 'Habilitado', '1'),
(91, 1, 91, 25.13, 91, '2019-05-01', 'Habilitado', '1'),
(92, 1, 92, 63.84, 92, '2019-05-01', 'Habilitado', '1'),
(93, 1, 93, 65, 93, '2019-05-01', 'Habilitado', '1'),
(94, 1, 94, 42.05, 94, '2019-05-01', 'Habilitado', '1'),
(95, 1, 95, 19.61, 95, '2019-05-01', 'Habilitado', '1'),
(96, 1, 96, 62.43, 96, '2019-05-01', 'Habilitado', '1'),
(97, 1, 97, 63.84, 97, '2019-05-01', 'Habilitado', '1'),
(98, 1, 98, 62.69, 98, '2019-05-01', 'Habilitado', '1'),
(99, 1, 99, 64.48, 99, '2019-05-01', 'Habilitado', '1'),
(100, 1, 100, 69.48, 100, '2019-05-01', 'Habilitado', '1'),
(101, 1, 101, 64.1, 101, '2019-05-01', 'Habilitado', '1'),
(102, 1, 102, 64.36, 102, '2019-05-01', 'Habilitado', '1'),
(103, 1, 103, 49.61, 103, '2019-05-01', 'Habilitado', '1'),
(104, 1, 104, 65.38, 104, '2019-05-01', 'Habilitado', '1'),
(105, 1, 105, 25.77, 105, '2019-05-01', 'Habilitado', '1'),
(106, 1, 106, 24.87, 106, '2019-05-01', 'Habilitado', '1'),
(107, 1, 107, 51.92, 107, '2019-05-01', 'Habilitado', '1'),
(108, 1, 108, 49.87, 108, '2019-05-01', 'Habilitado', '1'),
(109, 1, 109, 36.41, 109, '2019-05-01', 'Habilitado', '1'),
(110, 1, 110, 56.02, 110, '2019-05-01', 'Habilitado', '1'),
(111, 1, 111, 64.48, 111, '2019-05-01', 'Habilitado', '1'),
(112, 1, 112, 71.92, 112, '2019-05-01', 'Habilitado', '1'),
(113, 1, 113, 23.08, 113, '2019-05-01', 'Habilitado', '1'),
(114, 1, 114, 29.74, 114, '2019-05-01', 'Habilitado', '1'),
(115, 1, 115, 12.82, 115, '2019-05-01', 'Habilitado', '1'),
(116, 1, 116, 51.28, 116, '2019-05-01', 'Habilitado', '1'),
(117, 1, 117, 51.28, 117, '2019-05-01', 'Habilitado', '1'),
(118, 1, 118, 24.61, 118, '2019-05-01', 'Habilitado', '1'),
(119, 1, 119, 26.41, 119, '2019-05-01', 'Habilitado', '1'),
(120, 1, 120, 49.87, 120, '2019-05-01', 'Habilitado', '1'),
(121, 1, 121, 52.43, 121, '2019-05-01', 'Habilitado', '1'),
(122, 1, 122, 51.41, 122, '2019-05-01', 'Habilitado', '1'),
(123, 1, 123, 107.18, 123, '2019-05-01', 'Habilitado', '1'),
(124, 1, 124, 282.04, 124, '2019-05-01', 'Habilitado', '1'),
(125, 1, 125, 51.79, 125, '2019-05-01', 'Habilitado', '1'),
(126, 1, 126, 50.64, 126, '2019-05-01', 'Habilitado', '1'),
(127, 1, 127, 60.77, 127, '2019-05-01', 'Habilitado', '1'),
(128, 1, 128, 55.13, 128, '2019-05-01', 'Habilitado', '1'),
(129, 1, 129, 45.77, 129, '2019-05-01', 'Habilitado', '1'),
(130, 1, 130, 64.23, 130, '2019-05-01', 'Habilitado', '1'),
(131, 1, 131, 64.1, 131, '2019-05-01', 'Habilitado', '1'),
(132, 1, 132, 10.26, 132, '2019-05-01', 'Habilitado', '1'),
(133, 1, 133, 53.84, 133, '2019-05-01', 'Habilitado', '1'),
(134, 1, 134, 25.38, 134, '2019-05-01', 'Habilitado', '1'),
(135, 1, 135, 38.72, 135, '2019-05-01', 'Habilitado', '1'),
(136, 1, 136, 31.67, 136, '2019-05-01', 'Habilitado', '1'),
(137, 1, 137, 33.08, 137, '2019-05-01', 'Habilitado', '1'),
(138, 1, 138, 64.1, 138, '2019-05-01', 'Habilitado', '1'),
(139, 1, 139, 64.1, 139, '2019-05-01', 'Habilitado', '1'),
(140, 1, 140, 64.1, 140, '2019-05-01', 'Habilitado', '1'),
(141, 1, 141, 64.1, 141, '2019-05-01', 'Habilitado', '1'),
(142, 1, 142, 64.1, 142, '2019-05-01', 'Habilitado', '1'),
(143, 1, 143, 64.1, 143, '2019-05-01', 'Habilitado', '1'),
(144, 1, 144, 64.1, 144, '2019-05-01', 'Habilitado', '1'),
(145, 1, 145, 51.28, 145, '2019-05-01', 'Habilitado', '1'),
(146, 1, 146, 51.28, 146, '2019-05-01', 'Habilitado', '1'),
(147, 1, 147, 36.67, 147, '2019-05-01', 'Habilitado', '1'),
(148, 1, 148, 29.1, 148, '2019-05-01', 'Habilitado', '1'),
(149, 1, 149, 128.46, 149, '2019-05-01', 'Habilitado', '1'),
(150, 1, 150, 12.31, 150, '2019-05-01', 'Habilitado', '1'),
(151, 1, 151, 9.23, 151, '2019-05-01', 'Habilitado', '1'),
(152, 1, 152, 24.74, 152, '2019-05-01', 'Habilitado', '1'),
(153, 1, 153, 9.74, 153, '2019-05-01', 'Habilitado', '1'),
(154, 1, 154, 9.36, 154, '2019-05-01', 'Habilitado', '1'),
(155, 1, 155, 24.36, 155, '2019-05-01', 'Habilitado', '1'),
(156, 1, 156, 5.51, 156, '2019-05-01', 'Habilitado', '1'),
(157, 1, 157, 59.23, 157, '2019-05-01', 'Habilitado', '1'),
(158, 1, 158, 38.33, 158, '2019-05-01', 'Habilitado', '1'),
(159, 1, 159, 40.25, 159, '2019-05-01', 'Habilitado', '1'),
(160, 1, 160, 64.74, 160, '2019-05-01', 'Habilitado', '1'),
(161, 1, 161, 13.33, 161, '2019-05-01', 'Habilitado', '1'),
(162, 1, 162, 15.38, 162, '2019-05-01', 'Habilitado', '1'),
(163, 1, 163, 60, 163, '2019-05-01', 'Habilitado', '1'),
(164, 1, 164, 54.74, 164, '2019-05-01', 'Habilitado', '1'),
(165, 1, 165, 65.51, 165, '2019-05-01', 'Habilitado', '1'),
(166, 1, 166, 56.92, 166, '2019-05-01', 'Habilitado', '1'),
(167, 1, 167, 64.1, 167, '2019-05-01', 'Habilitado', '1'),
(168, 1, 168, 30.38, 168, '2019-05-01', 'Habilitado', '1'),
(169, 1, 169, 64.1, 169, '2019-05-01', 'Habilitado', '1'),
(170, 1, 170, 12.82, 170, '2019-05-01', 'Habilitado', '1'),
(171, 1, 171, 62.56, 171, '2019-05-01', 'Habilitado', '1'),
(172, 1, 172, 14.36, 172, '2019-05-01', 'Habilitado', '1'),
(173, 1, 173, 60.25, 173, '2019-05-01', 'Habilitado', '1'),
(174, 1, 174, 25.64, 174, '2019-05-01', 'Habilitado', '1'),
(175, 1, 175, 48.72, 175, '2019-05-01', 'Habilitado', '1'),
(176, 1, 176, 44.1, 176, '2019-05-01', 'Habilitado', '1'),
(177, 1, 177, 33.46, 177, '2019-05-01', 'Habilitado', '1'),
(178, 1, 178, 63.07, 178, '2019-05-01', 'Habilitado', '1'),
(179, 1, 179, 64.1, 179, '2019-05-01', 'Habilitado', '1'),
(180, 1, 180, 64.1, 180, '2019-05-01', 'Habilitado', '1'),
(181, 1, 181, 19.87, 181, '2019-05-01', 'Habilitado', '1'),
(182, 1, 182, 14.61, 182, '2019-05-01', 'Habilitado', '1'),
(183, 1, 183, 12.82, 183, '2019-05-01', 'Habilitado', '1'),
(184, 1, 184, 192.3, 184, '2019-05-01', 'Habilitado', '1'),
(185, 1, 185, 32.69, 185, '2019-05-01', 'Habilitado', '1'),
(186, 1, 186, 23.46, 186, '2019-05-01', 'Habilitado', '1'),
(187, 1, 187, 37.95, 187, '2019-05-01', 'Habilitado', '1'),
(188, 1, 188, 26.28, 188, '2019-05-01', 'Habilitado', '1'),
(189, 1, 189, 50.64, 189, '2019-05-01', 'Habilitado', '1'),
(190, 1, 190, 24.87, 190, '2019-05-01', 'Habilitado', '1'),
(191, 1, 191, 52.69, 191, '2019-05-01', 'Habilitado', '1'),
(192, 1, 192, 51.28, 192, '2019-05-01', 'Habilitado', '1'),
(193, 1, 193, 20.77, 193, '2019-05-01', 'Habilitado', '1'),
(194, 1, 194, 48.59, 194, '2019-05-01', 'Habilitado', '1'),
(195, 1, 195, 14.74, 195, '2019-05-01', 'Habilitado', '1'),
(196, 1, 196, 36.28, 196, '2019-05-01', 'Habilitado', '1'),
(197, 1, 197, 128.2, 197, '2019-05-01', 'Habilitado', '1'),
(198, 1, 198, 48.46, 198, '2019-05-01', 'Habilitado', '1'),
(199, 1, 199, 50.64, 199, '2019-05-01', 'Habilitado', '1'),
(200, 1, 200, 25.64, 200, '2019-05-01', 'Habilitado', '1'),
(201, 1, 201, 39.36, 201, '2019-05-01', 'Habilitado', '1'),
(202, 1, 202, 25.64, 202, '2019-05-01', 'Habilitado', '1'),
(203, 1, 203, 12.82, 203, '2019-05-01', 'Habilitado', '1'),
(204, 1, 204, 59.23, 204, '2019-05-01', 'Habilitado', '1'),
(205, 1, 205, 41.02, 205, '2019-05-01', 'Habilitado', '1'),
(206, 1, 206, 33.33, 206, '2019-05-01', 'Habilitado', '1'),
(207, 1, 207, 11.79, 207, '2019-05-01', 'Habilitado', '1'),
(208, 1, 208, 47.95, 208, '2019-05-01', 'Habilitado', '1'),
(209, 1, 209, 63.59, 209, '2019-05-01', 'Habilitado', '1'),
(210, 1, 210, 50.51, 210, '2019-05-01', 'Habilitado', '1'),
(211, 1, 211, 25.64, 211, '2019-05-01', 'Habilitado', '1'),
(212, 1, 212, 53.59, 212, '2019-05-01', 'Habilitado', '1'),
(213, 1, 213, 38.46, 213, '2019-05-01', 'Habilitado', '1'),
(214, 1, 214, 25.64, 214, '2019-05-01', 'Habilitado', '1'),
(215, 1, 215, 26.02, 215, '2019-05-01', 'Habilitado', '1'),
(216, 1, 216, 50.13, 216, '2019-05-01', 'Habilitado', '1'),
(217, 1, 217, 50.64, 217, '2019-05-01', 'Habilitado', '1'),
(218, 1, 218, 15.26, 218, '2019-05-01', 'Habilitado', '1'),
(219, 1, 219, 31.28, 219, '2019-05-01', 'Habilitado', '1'),
(220, 1, 220, 59.36, 220, '2019-05-01', 'Habilitado', '1'),
(221, 1, 221, 23.46, 221, '2019-05-01', 'Habilitado', '1'),
(222, 1, 222, 48.08, 222, '2019-05-01', 'Habilitado', '1'),
(223, 1, 223, 51.28, 223, '2019-05-01', 'Habilitado', '1'),
(224, 1, 224, 50.51, 224, '2019-05-01', 'Habilitado', '1'),
(225, 1, 225, 51.41, 225, '2019-05-01', 'Habilitado', '1'),
(226, 1, 226, 49.1, 226, '2019-05-01', 'Habilitado', '1'),
(227, 1, 227, 56.79, 227, '2019-05-01', 'Habilitado', '1'),
(228, 1, 228, 58.33, 228, '2019-05-01', 'Habilitado', '1'),
(229, 1, 229, 50, 229, '2019-05-01', 'Habilitado', '1'),
(230, 1, 230, 50.9, 230, '2019-05-01', 'Habilitado', '1'),
(231, 1, 231, 70.64, 231, '2019-05-01', 'Habilitado', '1'),
(232, 1, 232, 48.33, 232, '2019-05-01', 'Habilitado', '1'),
(233, 1, 233, 10.77, 233, '2019-05-01', 'Habilitado', '1'),
(234, 1, 234, 12.44, 234, '2019-05-01', 'Habilitado', '1'),
(235, 1, 235, 12.82, 235, '2019-05-01', 'Habilitado', '1'),
(236, 1, 236, 64.1, 236, '2019-05-01', 'Habilitado', '1'),
(237, 1, 237, 13.2, 237, '2019-05-01', 'Habilitado', '1'),
(238, 1, 238, 15.9, 238, '2019-05-01', 'Habilitado', '1'),
(239, 1, 239, 4.23, 239, '2019-05-01', 'Habilitado', '1'),
(240, 1, 240, 44.87, 240, '2019-05-01', 'Habilitado', '1'),
(241, 1, 241, 77.18, 241, '2019-05-01', 'Habilitado', '1'),
(242, 1, 242, 61.54, 242, '2019-05-01', 'Habilitado', '1'),
(243, 1, 243, 35.26, 243, '2019-05-01', 'Habilitado', '1'),
(244, 1, 244, 65.13, 244, '2019-05-01', 'Habilitado', '1'),
(245, 1, 245, 64.1, 245, '2019-05-01', 'Habilitado', '1'),
(246, 1, 246, 38.72, 246, '2019-05-01', 'Habilitado', '1'),
(247, 1, 247, 23.59, 247, '2019-05-01', 'Habilitado', '1'),
(248, 1, 248, 51.28, 248, '2019-05-01', 'Habilitado', '1'),
(249, 1, 249, 51.28, 249, '2019-05-01', 'Habilitado', '1'),
(250, 1, 250, 64.87, 250, '2019-05-01', 'Habilitado', '1'),
(251, 1, 251, 12.95, 251, '2019-05-01', 'Habilitado', '1'),
(252, 1, 252, 23.97, 252, '2019-05-01', 'Habilitado', '1'),
(253, 1, 253, 12.82, 253, '2019-05-01', 'Habilitado', '1'),
(254, 1, 254, 12.82, 254, '2019-05-01', 'Habilitado', '1'),
(255, 1, 255, 22.95, 255, '2019-05-01', 'Habilitado', '1'),
(256, 1, 256, 29.1, 256, '2019-05-01', 'Habilitado', '1'),
(257, 1, 257, 48.46, 257, '2019-05-01', 'Habilitado', '1'),
(258, 1, 258, 64.1, 258, '2019-05-01', 'Habilitado', '1'),
(259, 1, 259, 23.59, 259, '2019-05-01', 'Habilitado', '1'),
(260, 1, 260, 36.28, 260, '2019-05-01', 'Habilitado', '1'),
(261, 2, 42, 9.6, 1, '2019-05-01', 'Habilitado', '1'),
(262, 2, 43, 9.6, 2, '2019-05-01', 'Habilitado', '1'),
(263, 2, 44, 12, 3, '2019-05-01', 'Habilitado', '1'),
(264, 2, 45, 19.58, 4, '2019-05-01', 'Habilitado', '1'),
(265, 2, 46, 11.9, 5, '2019-05-01', 'Habilitado', '1'),
(266, 2, 47, 18.72, 6, '2019-05-01', 'Habilitado', '1'),
(267, 2, 48, 30.62, 7, '2019-05-01', 'Habilitado', '1'),
(268, 2, 49, 8.93, 8, '2019-05-01', 'Habilitado', '1'),
(269, 2, 50, 9.12, 9, '2019-05-01', 'Habilitado', '1'),
(270, 2, 51, 10.08, 10, '2019-05-01', 'Habilitado', '1'),
(271, 2, 52, 9.89, 11, '2019-05-01', 'Habilitado', '1'),
(272, 2, 53, 38.4, 12, '2019-05-01', 'Habilitado', '1'),
(273, 2, 54, 9.41, 13, '2019-05-01', 'Habilitado', '1'),
(274, 2, 55, 12.19, 14, '2019-05-01', 'Habilitado', '1'),
(275, 2, 56, 8.74, 15, '2019-05-01', 'Habilitado', '1'),
(276, 2, 57, 46.46, 16, '2019-05-01', 'Habilitado', '1'),
(277, 2, 58, 38.4, 17, '2019-05-01', 'Habilitado', '1'),
(278, 2, 59, 26.21, 18, '2019-05-01', 'Habilitado', '1'),
(279, 2, 60, 27.07, 19, '2019-05-01', 'Habilitado', '1'),
(280, 2, 61, 9.79, 20, '2019-05-01', 'Habilitado', '1'),
(281, 2, 62, 8.64, 21, '2019-05-01', 'Habilitado', '1'),
(282, 2, 63, 11.81, 22, '2019-05-01', 'Habilitado', '1'),
(283, 2, 64, 21.79, 23, '2019-05-01', 'Habilitado', '1'),
(284, 2, 65, 46.85, 24, '2019-05-01', 'Habilitado', '1'),
(285, 2, 66, 49.44, 25, '2019-05-01', 'Habilitado', '1'),
(286, 2, 67, 19.78, 26, '2019-05-01', 'Habilitado', '1'),
(287, 2, 68, 29.38, 27, '2019-05-01', 'Habilitado', '1'),
(288, 2, 69, 48, 28, '2019-05-01', 'Habilitado', '1'),
(289, 2, 70, 48.67, 29, '2019-05-01', 'Habilitado', '1'),
(290, 2, 71, 10.37, 30, '2019-05-01', 'Habilitado', '1'),
(291, 2, 72, 36.86, 31, '2019-05-01', 'Habilitado', '1'),
(292, 2, 73, 15.36, 32, '2019-05-01', 'Habilitado', '1'),
(293, 2, 74, 78.72, 33, '2019-05-01', 'Habilitado', '1'),
(294, 2, 75, 16.61, 34, '2019-05-01', 'Habilitado', '1'),
(295, 2, 76, 14.78, 35, '2019-05-01', 'Habilitado', '1'),
(296, 2, 77, 13.54, 36, '2019-05-01', 'Habilitado', '1'),
(297, 2, 78, 4.99, 37, '2019-05-01', 'Habilitado', '1'),
(298, 2, 79, 14.11, 38, '2019-05-01', 'Habilitado', '1'),
(299, 2, 80, 14.4, 39, '2019-05-01', 'Habilitado', '1'),
(300, 2, 81, 16.13, 40, '2019-05-01', 'Habilitado', '1'),
(301, 2, 82, 15.84, 41, '2019-05-01', 'Habilitado', '1'),
(302, 2, 83, 38.21, 42, '2019-05-01', 'Habilitado', '1'),
(303, 2, 84, 48, 43, '2019-05-01', 'Habilitado', '1'),
(304, 2, 85, 55.3, 44, '2019-05-01', 'Habilitado', '1'),
(305, 2, 86, 43.01, 45, '2019-05-01', 'Habilitado', '1'),
(306, 2, 87, 38.4, 46, '2019-05-01', 'Habilitado', '1'),
(307, 2, 88, 47.81, 47, '2019-05-01', 'Habilitado', '1'),
(308, 2, 89, 49.25, 48, '2019-05-01', 'Habilitado', '1'),
(309, 2, 90, 47.42, 49, '2019-05-01', 'Habilitado', '1'),
(310, 2, 91, 18.82, 50, '2019-05-01', 'Habilitado', '1'),
(311, 2, 92, 47.81, 51, '2019-05-01', 'Habilitado', '1'),
(312, 2, 93, 48.67, 52, '2019-05-01', 'Habilitado', '1'),
(313, 2, 94, 31.49, 53, '2019-05-01', 'Habilitado', '1'),
(314, 2, 95, 14.69, 54, '2019-05-01', 'Habilitado', '1'),
(315, 2, 96, 46.75, 55, '2019-05-01', 'Habilitado', '1'),
(316, 2, 97, 47.81, 56, '2019-05-01', 'Habilitado', '1'),
(317, 2, 98, 46.94, 57, '2019-05-01', 'Habilitado', '1'),
(318, 2, 99, 48.29, 58, '2019-05-01', 'Habilitado', '1'),
(319, 2, 100, 52.03, 59, '2019-05-01', 'Habilitado', '1'),
(320, 2, 101, 48, 60, '2019-05-01', 'Habilitado', '1'),
(321, 2, 102, 48.19, 61, '2019-05-01', 'Habilitado', '1'),
(322, 2, 103, 37.15, 62, '2019-05-01', 'Habilitado', '1'),
(323, 2, 104, 48.96, 63, '2019-05-01', 'Habilitado', '1'),
(324, 2, 105, 19.3, 64, '2019-05-01', 'Habilitado', '1'),
(325, 2, 106, 18.62, 65, '2019-05-01', 'Habilitado', '1'),
(326, 2, 107, 38.88, 66, '2019-05-01', 'Habilitado', '1'),
(327, 2, 108, 37.34, 67, '2019-05-01', 'Habilitado', '1'),
(328, 2, 109, 27.26, 68, '2019-05-01', 'Habilitado', '1'),
(329, 2, 110, 41.95, 69, '2019-05-01', 'Habilitado', '1'),
(330, 2, 111, 48.29, 70, '2019-05-01', 'Habilitado', '1'),
(331, 2, 112, 53.86, 71, '2019-05-01', 'Habilitado', '1'),
(332, 2, 113, 17.28, 72, '2019-05-01', 'Habilitado', '1'),
(333, 2, 114, 22.27, 73, '2019-05-01', 'Habilitado', '1'),
(334, 2, 115, 9.6, 74, '2019-05-01', 'Habilitado', '1'),
(335, 2, 116, 38.4, 75, '2019-05-01', 'Habilitado', '1'),
(336, 2, 117, 38.4, 76, '2019-05-01', 'Habilitado', '1'),
(337, 2, 118, 18.43, 77, '2019-05-01', 'Habilitado', '1'),
(338, 2, 119, 19.78, 78, '2019-05-01', 'Habilitado', '1'),
(339, 2, 120, 37.34, 79, '2019-05-01', 'Habilitado', '1'),
(340, 2, 121, 39.26, 80, '2019-05-01', 'Habilitado', '1'),
(341, 2, 122, 38.5, 81, '2019-05-01', 'Habilitado', '1'),
(342, 2, 123, 80.26, 82, '2019-05-01', 'Habilitado', '1'),
(343, 2, 124, 211.2, 83, '2019-05-01', 'Habilitado', '1'),
(344, 2, 125, 38.78, 84, '2019-05-01', 'Habilitado', '1'),
(345, 2, 126, 37.92, 85, '2019-05-01', 'Habilitado', '1'),
(346, 2, 127, 45.5, 86, '2019-05-01', 'Habilitado', '1'),
(347, 2, 128, 41.28, 87, '2019-05-01', 'Habilitado', '1'),
(348, 2, 129, 34.27, 88, '2019-05-01', 'Habilitado', '1'),
(349, 3, 130, 21.04, 1, '2019-05-01', 'Habilitado', '1'),
(350, 3, 131, 21, 2, '2019-05-01', 'Habilitado', '1'),
(351, 3, 132, 3.36, 3, '2019-05-01', 'Habilitado', '1'),
(352, 3, 133, 17.64, 4, '2019-05-01', 'Habilitado', '1'),
(353, 3, 134, 8.32, 5, '2019-05-01', 'Habilitado', '1'),
(354, 3, 135, 12.68, 6, '2019-05-01', 'Habilitado', '1'),
(355, 3, 136, 10.37, 7, '2019-05-01', 'Habilitado', '1'),
(356, 3, 137, 10.84, 8, '2019-05-01', 'Habilitado', '1'),
(357, 3, 138, 21, 9, '2019-05-01', 'Habilitado', '1'),
(358, 3, 139, 21, 10, '2019-05-01', 'Habilitado', '1'),
(359, 3, 140, 21, 11, '2019-05-01', 'Habilitado', '1'),
(360, 3, 141, 21, 12, '2019-05-01', 'Habilitado', '1'),
(361, 3, 142, 21, 13, '2019-05-01', 'Habilitado', '1'),
(362, 3, 143, 21, 14, '2019-05-01', 'Habilitado', '1'),
(363, 3, 144, 21, 15, '2019-05-01', 'Habilitado', '1'),
(364, 3, 145, 16.8, 16, '2019-05-01', 'Habilitado', '1'),
(365, 3, 146, 16.8, 17, '2019-05-01', 'Habilitado', '1'),
(366, 3, 147, 12.01, 18, '2019-05-01', 'Habilitado', '1'),
(367, 3, 148, 9.53, 19, '2019-05-01', 'Habilitado', '1'),
(368, 3, 149, 42.08, 20, '2019-05-01', 'Habilitado', '1'),
(369, 3, 150, 4.03, 21, '2019-05-01', 'Habilitado', '1'),
(370, 3, 151, 3.02, 22, '2019-05-01', 'Habilitado', '1'),
(371, 3, 152, 8.11, 23, '2019-05-01', 'Habilitado', '1'),
(372, 3, 153, 3.19, 24, '2019-05-01', 'Habilitado', '1'),
(373, 3, 154, 3.07, 25, '2019-05-01', 'Habilitado', '1'),
(374, 3, 155, 7.98, 26, '2019-05-01', 'Habilitado', '1'),
(375, 3, 156, 1.81, 27, '2019-05-01', 'Habilitado', '1'),
(376, 3, 157, 19.4, 28, '2019-05-01', 'Habilitado', '1'),
(377, 3, 158, 12.56, 29, '2019-05-01', 'Habilitado', '1'),
(378, 3, 159, 13.19, 30, '2019-05-01', 'Habilitado', '1'),
(379, 3, 160, 21.21, 31, '2019-05-01', 'Habilitado', '1'),
(380, 3, 161, 4.37, 32, '2019-05-01', 'Habilitado', '1'),
(381, 3, 162, 5.04, 33, '2019-05-01', 'Habilitado', '1'),
(382, 3, 163, 19.66, 34, '2019-05-01', 'Habilitado', '1'),
(383, 3, 164, 17.93, 35, '2019-05-01', 'Habilitado', '1'),
(384, 3, 165, 21.46, 36, '2019-05-01', 'Habilitado', '1'),
(385, 3, 166, 18.65, 37, '2019-05-01', 'Habilitado', '1'),
(386, 3, 167, 21, 38, '2019-05-01', 'Habilitado', '1'),
(387, 3, 168, 9.95, 39, '2019-05-01', 'Habilitado', '1'),
(388, 3, 169, 21, 40, '2019-05-01', 'Habilitado', '1'),
(389, 3, 170, 4.2, 41, '2019-05-01', 'Habilitado', '1'),
(390, 3, 171, 20.5, 42, '2019-05-01', 'Habilitado', '1'),
(391, 3, 172, 4.7, 43, '2019-05-01', 'Habilitado', '1'),
(392, 3, 173, 19.74, 44, '2019-05-01', 'Habilitado', '1'),
(393, 3, 174, 8.4, 45, '2019-05-01', 'Habilitado', '1'),
(394, 3, 175, 15.96, 46, '2019-05-01', 'Habilitado', '1'),
(395, 3, 176, 14.45, 47, '2019-05-01', 'Habilitado', '1'),
(396, 3, 177, 10.96, 48, '2019-05-01', 'Habilitado', '1'),
(397, 3, 178, 20.66, 49, '2019-05-01', 'Habilitado', '1'),
(398, 3, 179, 21, 50, '2019-05-01', 'Habilitado', '1'),
(399, 3, 180, 21, 51, '2019-05-01', 'Habilitado', '1'),
(400, 3, 181, 6.51, 52, '2019-05-01', 'Habilitado', '1'),
(401, 3, 182, 4.79, 53, '2019-05-01', 'Habilitado', '1'),
(402, 3, 183, 4.2, 54, '2019-05-01', 'Habilitado', '1'),
(403, 3, 184, 63, 55, '2019-05-01', 'Habilitado', '1'),
(404, 3, 185, 10.71, 56, '2019-05-01', 'Habilitado', '1'),
(405, 3, 186, 7.69, 57, '2019-05-01', 'Habilitado', '1'),
(406, 3, 187, 12.43, 58, '2019-05-01', 'Habilitado', '1'),
(407, 3, 188, 8.61, 59, '2019-05-01', 'Habilitado', '1'),
(408, 3, 189, 16.59, 60, '2019-05-01', 'Habilitado', '1'),
(409, 3, 190, 8.15, 61, '2019-05-01', 'Habilitado', '1'),
(410, 3, 191, 17.26, 62, '2019-05-01', 'Habilitado', '1'),
(411, 3, 192, 16.8, 63, '2019-05-01', 'Habilitado', '1'),
(412, 3, 193, 6.8, 64, '2019-05-01', 'Habilitado', '1'),
(413, 3, 194, 15.92, 65, '2019-05-01', 'Habilitado', '1'),
(414, 3, 195, 4.83, 66, '2019-05-01', 'Habilitado', '1'),
(415, 3, 196, 11.89, 67, '2019-05-01', 'Habilitado', '1'),
(416, 3, 197, 42, 68, '2019-05-01', 'Habilitado', '1'),
(417, 3, 198, 15.88, 69, '2019-05-01', 'Habilitado', '1'),
(418, 3, 199, 16.59, 70, '2019-05-01', 'Habilitado', '1'),
(419, 3, 200, 8.4, 71, '2019-05-01', 'Habilitado', '1'),
(420, 3, 201, 12.89, 72, '2019-05-01', 'Habilitado', '1'),
(421, 3, 202, 8.4, 73, '2019-05-01', 'Habilitado', '1'),
(422, 3, 203, 4.2, 74, '2019-05-01', 'Habilitado', '1'),
(423, 3, 204, 19.4, 75, '2019-05-01', 'Habilitado', '1'),
(424, 3, 205, 13.44, 76, '2019-05-01', 'Habilitado', '1'),
(425, 4, 206, 62.4, 1, '2019-05-01', 'Habilitado', '1'),
(426, 4, 207, 22.08, 2, '2019-05-01', 'Habilitado', '1'),
(427, 4, 208, 89.76, 3, '2019-05-01', 'Habilitado', '1'),
(428, 4, 209, 119.04, 4, '2019-05-01', 'Habilitado', '1'),
(429, 4, 210, 94.56, 5, '2019-05-01', 'Habilitado', '1'),
(430, 4, 211, 48, 6, '2019-05-01', 'Habilitado', '1'),
(431, 4, 212, 100.32, 7, '2019-05-01', 'Habilitado', '1'),
(432, 4, 213, 72, 8, '2019-05-01', 'Habilitado', '1'),
(433, 4, 214, 48, 9, '2019-05-01', 'Habilitado', '1'),
(434, 4, 215, 48.72, 10, '2019-05-01', 'Habilitado', '1'),
(435, 4, 216, 93.84, 11, '2019-05-01', 'Habilitado', '1'),
(436, 4, 217, 94.8, 12, '2019-05-01', 'Habilitado', '1'),
(437, 4, 218, 28.56, 13, '2019-05-01', 'Habilitado', '1'),
(438, 4, 219, 58.56, 14, '2019-05-01', 'Habilitado', '1'),
(439, 5, 220, 53.25, 1, '2019-05-01', 'Habilitado', '1'),
(440, 5, 221, 21.05, 2, '2019-05-01', 'Habilitado', '1'),
(441, 5, 222, 43.13, 3, '2019-05-01', 'Habilitado', '1'),
(442, 5, 223, 46, 4, '2019-05-01', 'Habilitado', '1'),
(443, 5, 224, 45.31, 5, '2019-05-01', 'Habilitado', '1'),
(444, 5, 225, 46.12, 6, '2019-05-01', 'Habilitado', '1'),
(445, 5, 226, 44.05, 7, '2019-05-01', 'Habilitado', '1'),
(446, 5, 227, 50.95, 8, '2019-05-01', 'Habilitado', '1'),
(447, 5, 228, 52.33, 9, '2019-05-01', 'Habilitado', '1'),
(448, 5, 229, 44.85, 10, '2019-05-01', 'Habilitado', '1'),
(449, 5, 230, 45.66, 11, '2019-05-01', 'Habilitado', '1'),
(450, 5, 231, 63.37, 12, '2019-05-01', 'Habilitado', '1'),
(451, 5, 232, 43.36, 13, '2019-05-01', 'Habilitado', '1'),
(452, 5, 233, 9.66, 14, '2019-05-01', 'Habilitado', '1'),
(453, 5, 234, 11.16, 15, '2019-05-01', 'Habilitado', '1'),
(454, 5, 235, 11.5, 16, '2019-05-01', 'Habilitado', '1'),
(455, 5, 236, 57.5, 17, '2019-05-01', 'Habilitado', '1'),
(456, 5, 237, 11.85, 18, '2019-05-01', 'Habilitado', '1'),
(457, 5, 238, 14.26, 19, '2019-05-01', 'Habilitado', '1'),
(458, 5, 239, 3.8, 20, '2019-05-01', 'Habilitado', '1'),
(459, 5, 240, 40.25, 21, '2019-05-01', 'Habilitado', '1'),
(460, 5, 241, 69.23, 22, '2019-05-01', 'Habilitado', '1'),
(461, 5, 242, 55.2, 23, '2019-05-01', 'Habilitado', '1'),
(462, 5, 243, 31.63, 24, '2019-05-01', 'Habilitado', '1'),
(463, 5, 244, 58.42, 25, '2019-05-01', 'Habilitado', '1'),
(464, 5, 245, 57.5, 26, '2019-05-01', 'Habilitado', '1'),
(465, 5, 246, 34.73, 27, '2019-05-01', 'Habilitado', '1'),
(466, 5, 247, 21.16, 28, '2019-05-01', 'Habilitado', '1'),
(467, 5, 248, 46, 29, '2019-05-01', 'Habilitado', '1'),
(468, 5, 249, 46, 30, '2019-05-01', 'Habilitado', '1'),
(469, 5, 250, 58.19, 31, '2019-05-01', 'Habilitado', '1'),
(470, 5, 251, 11.62, 32, '2019-05-01', 'Habilitado', '1'),
(471, 5, 252, 21.51, 33, '2019-05-01', 'Habilitado', '1'),
(472, 5, 253, 11.5, 34, '2019-05-01', 'Habilitado', '1'),
(473, 5, 254, 11.5, 35, '2019-05-01', 'Habilitado', '1'),
(474, 5, 255, 20.59, 36, '2019-05-01', 'Habilitado', '1'),
(475, 5, 256, 26.11, 37, '2019-05-01', 'Habilitado', '1'),
(476, 5, 257, 43.47, 38, '2019-05-01', 'Habilitado', '1'),
(477, 5, 258, 57.5, 39, '2019-05-01', 'Habilitado', '1'),
(478, 5, 259, 21.16, 40, '2019-05-01', 'Habilitado', '1'),
(479, 5, 260, 32.55, 41, '2019-05-01', 'Habilitado', '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `det_asamb_canal`
--

CREATE TABLE `det_asamb_canal` (
  `id_dt_asmb_canal` int(11) NOT NULL,
  `id_asamblea` int(11) DEFAULT NULL,
  `id_canal` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Volcado de datos para la tabla `det_asamb_canal`
--

INSERT INTO `det_asamb_canal` (`id_dt_asmb_canal`, `id_asamblea`, `id_canal`) VALUES
(16, 62, 3),
(19, 65, 3),
(22, 68, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `det_limpieza`
--

CREATE TABLE `det_limpieza` (
  `id_det_limpieza` int(11) NOT NULL,
  `id_destajo` int(11) DEFAULT NULL,
  `id_limpieza` int(11) DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `det_lista`
--

CREATE TABLE `det_lista` (
  `id_det_lista` int(11) NOT NULL,
  `id_lista` int(11) DEFAULT NULL,
  `id_auth_user` int(11) DEFAULT NULL,
  `cargo` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direccion`
--

CREATE TABLE `direccion` (
  `id_direccion` int(11) NOT NULL,
  `id_datos_personales` int(11) DEFAULT NULL,
  `pais` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `cod_postal` int(11) DEFAULT NULL,
  `departamento` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `provinciaa` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `distrito` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `dir_larga` varchar(100) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext COLLATE hp8_bin,
  `object_repr` varchar(200) COLLATE hp8_bin NOT NULL,
  `action_flag` smallint(5) UNSIGNED NOT NULL,
  `change_message` longtext COLLATE hp8_bin NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_admin_log`
--

INSERT INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
(1, '2018-10-24 14:00:45.888346', '3', 'Canalero', 2, '[{\"changed\": {\"fields\": [\"user_permissions\"]}}]', 4, 1),
(2, '2018-10-24 14:00:56.459897', '2', 'Presidente', 2, '[{\"changed\": {\"fields\": [\"user_permissions\"]}}]', 4, 1),
(3, '2018-10-27 03:58:43.027307', '9', 'Shando', 3, '', 4, 1),
(4, '2018-11-09 00:07:50.198552', '11', 'Geral', 3, '', 4, 1),
(5, '2018-11-09 00:07:50.241524', '6', 'Gerardo', 3, '', 4, 1),
(6, '2018-11-09 00:07:50.298626', '12', 'Maria', 3, '', 4, 1),
(7, '2018-11-09 00:07:50.357250', '8', 'Mario', 3, '', 4, 1),
(8, '2018-11-09 00:07:50.379190', '7', 'Micaela', 3, '', 4, 1),
(9, '2018-11-09 00:07:50.390657', '10', 'Shando', 3, '', 4, 1),
(10, '2018-11-09 00:07:50.401338', '4', 'Tany', 3, '', 4, 1),
(11, '2018-11-09 00:13:39.848561', '11', 'Geral', 3, '', 4, 1),
(12, '2018-11-09 00:13:39.915356', '6', 'Gerardo', 3, '', 4, 1),
(13, '2018-11-09 00:13:39.927295', '12', 'Maria', 3, '', 4, 1),
(14, '2018-11-09 00:13:39.956216', '8', 'Mario', 3, '', 4, 1),
(15, '2018-11-09 00:13:40.048968', '7', 'Micaela', 3, '', 4, 1),
(16, '2018-11-09 00:13:40.059939', '10', 'Shando', 3, '', 4, 1),
(17, '2018-11-09 00:13:40.081880', '4', 'Tany', 3, '', 4, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) COLLATE hp8_bin NOT NULL,
  `model` varchar(100) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(1, 'admin', 'logentry'),
(3, 'auth', 'group'),
(2, 'auth', 'permission'),
(4, 'auth', 'user'),
(5, 'contenttypes', 'contenttype'),
(7, 'inicio', 'acceso'),
(29, 'inicio', 'agendaasamblea'),
(30, 'inicio', 'archivosparcela'),
(8, 'inicio', 'asamblea'),
(9, 'inicio', 'asistencia'),
(31, 'inicio', 'authgroup'),
(32, 'inicio', 'authgrouppermissions'),
(33, 'inicio', 'authpermission'),
(34, 'inicio', 'authuser'),
(35, 'inicio', 'authusergroups'),
(36, 'inicio', 'authuseruserpermissions'),
(10, 'inicio', 'canal'),
(11, 'inicio', 'caudal'),
(12, 'inicio', 'comite'),
(43, 'inicio', 'compmulta'),
(44, 'inicio', 'comporden'),
(13, 'inicio', 'comprobante'),
(37, 'inicio', 'datospersonales'),
(14, 'inicio', 'destajo'),
(48, 'inicio', 'detasambcanal'),
(15, 'inicio', 'detlimpieza'),
(16, 'inicio', 'detlista'),
(17, 'inicio', 'direccion'),
(38, 'inicio', 'djangoadminlog'),
(39, 'inicio', 'djangocontenttype'),
(40, 'inicio', 'djangomigrations'),
(41, 'inicio', 'djangosession'),
(42, 'inicio', 'hojaasistencia'),
(18, 'inicio', 'limpieza'),
(19, 'inicio', 'lista'),
(20, 'inicio', 'multa'),
(45, 'inicio', 'multaasistencia'),
(46, 'inicio', 'multalimpia'),
(47, 'inicio', 'multaorden'),
(21, 'inicio', 'noticia'),
(22, 'inicio', 'obra'),
(23, 'inicio', 'ordenriego'),
(24, 'inicio', 'parcela'),
(25, 'inicio', 'persona'),
(26, 'inicio', 'reparto'),
(27, 'inicio', 'talonario'),
(28, 'inicio', 'usuario'),
(6, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` int(11) NOT NULL,
  `app` varchar(255) COLLATE hp8_bin NOT NULL,
  `name` varchar(255) COLLATE hp8_bin NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2018-10-24 13:25:42.787826'),
(2, 'auth', '0001_initial', '2018-10-24 13:25:50.201390'),
(3, 'admin', '0001_initial', '2018-10-24 13:25:51.904184'),
(4, 'admin', '0002_logentry_remove_auto_add', '2018-10-24 13:25:51.967732'),
(5, 'admin', '0003_logentry_add_action_flag_choices', '2018-10-24 13:25:52.049807'),
(6, 'contenttypes', '0002_remove_content_type_name', '2018-10-24 13:25:52.803253'),
(7, 'auth', '0002_alter_permission_name_max_length', '2018-10-24 13:25:53.531835'),
(8, 'auth', '0003_alter_user_email_max_length', '2018-10-24 13:25:54.222407'),
(9, 'auth', '0004_alter_user_username_opts', '2018-10-24 13:25:54.320867'),
(10, 'auth', '0005_alter_user_last_login_null', '2018-10-24 13:25:54.892151'),
(11, 'auth', '0006_require_contenttypes_0002', '2018-10-24 13:25:54.941310'),
(12, 'auth', '0007_alter_validators_add_error_messages', '2018-10-24 13:25:55.004515'),
(13, 'auth', '0008_alter_user_username_max_length', '2018-10-24 13:25:55.554831'),
(14, 'auth', '0009_alter_user_last_name_max_length', '2018-10-24 13:25:56.145624'),
(15, 'sessions', '0001_initial', '2018-10-24 13:25:57.080944'),
(16, 'usuario', '0001_initial', '2018-10-24 14:00:09.350040'),
(17, 'canalero', '0001_initial', '2018-10-24 14:00:09.634887'),
(18, 'usuario', '0002_auto_20180912_1116', '2018-10-24 14:00:12.077464'),
(19, 'usuario', '0003_parcela', '2018-10-24 14:00:13.002116'),
(20, 'usuario', '0004_auto_20181011_1038', '2018-10-24 14:00:14.532277'),
(21, 'canalero', '0002_delete_reparto', '2018-10-24 14:00:14.877007'),
(22, 'inicio', '0001_initial', '2018-10-24 14:00:15.074979'),
(23, 'inicio', '0002_agendaasamblea_archivosparcela_authgroup_authgrouppermissions_authpermission_authuser_authusergroups', '2018-10-24 14:00:15.189204'),
(24, 'inicio', '0003_auto_20181017_1014', '2018-10-24 14:00:15.207290'),
(25, 'inicio', '0004_auto_20181017_1453', '2018-10-24 14:00:15.228086'),
(26, 'inicio', '0005_compmulta_comporden_multaasistencia_multalimpia_multaorden', '2018-10-24 22:39:18.896977'),
(27, 'auth', '0010_alter_group_name_max_length', '2019-07-28 07:35:21.456010'),
(28, 'auth', '0011_update_proxy_permissions', '2019-07-28 07:35:21.542846'),
(29, 'inicio', '0006_auto_20190728_0233', '2019-07-28 07:35:21.571745');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) COLLATE hp8_bin NOT NULL,
  `session_data` longtext COLLATE hp8_bin NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_session`
--

INSERT INTO `django_session` (`session_key`, `session_data`, `expire_date`) VALUES
('1ccvzwq4pslk9ndabwh2f7hvfsndob8i', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 20:35:58.926615'),
('1y5l67o1fmpxhaikumu5qj6r6mr2vmmp', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-02-28 00:53:35.679803'),
('3ynq9lanaqjfyvonmelghvsibh217o4u', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 05:55:23.754279'),
('3zseb4leg8pxordnbotypm5mmzyzl95q', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-15 03:09:49.811102'),
('4da8kkkeky53mglf3i0spz7r84ku3ts7', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-19 04:52:01.362211'),
('4fzqoitfrcwiylye5rs88fuwa6nsq0yf', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 01:34:12.307928'),
('4hsrjhngfddtsab470dt96a9moihr8x8', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:17:14.954273'),
('5t85ym829tstif20vlq49btj6aifvnpw', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-11-28 03:37:10.599686'),
('614iv2rnzoq295iiad7xb8ceek627zm5', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 06:04:09.693747'),
('61s69hw7qdu0788eefpxo08obzg3vg2d', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-11 01:53:00.245201'),
('65upvsxujm7t3y59qb7oxuew3ph1lbo4', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-19 04:47:26.986865'),
('6j921vm0alcg0wz2k08lpgi4p75gx1zm', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:32:40.030620'),
('75ckoeeh0w8vxzkgruxln3qlbt0788b5', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:13:34.211631'),
('7xqu9lccef9immkw1916gcpn2wq32p7e', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 20:45:29.740744'),
('8b5ngjr744ffw086fa7g60hvyqe5uvyz', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-02 02:35:43.897838'),
('aaw7rbb3gludd0shf70dppejvwrxvuin', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-03-23 03:07:20.731862'),
('asmv0z9zzrro17q0ukvl0em59gsdqjxe', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:15:10.598969'),
('avvx4stu9fbd0ya2e2edns6e8t1ycatf', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:04:39.247484'),
('b5w8bq7mc45ngk29ure7vbso5vja6gfg', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:12:34.787156'),
('bq9dq161ug15j8p9pnpc4zyxyqahbk6j', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-05-04 19:09:01.366379'),
('c56b5fzbkcobbiy105296r8twyq43w6o', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:12:16.006079'),
('cjotbhnry6ctyrecq5mhdkvrouczn0pw', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-16 16:32:36.082730'),
('clydvrz26t9rd03wltkflqjvh0nykwjc', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 14:17:19.304949'),
('d1p4cqa180eqzbgi4y5emxvwce9iw8zr', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2019-02-19 01:30:41.004640'),
('fjolhbix1iwfpn1byd21h7pwpkrklpek', 'ZjE4ZTg4OWVhMjc0MTg0NTUxMGU2YjcyZWZiZDk5MmYxYTE1NWMyNjp7fQ==', '2018-11-07 22:28:02.214088'),
('gece0q5sinynjff2gmhoc0baky6ffc1w', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:27:13.596974'),
('i13iymtpnpmegzvapg99zhed45fm5jpe', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-29 00:25:54.110431'),
('iu9ni74ux5u026buq34zrqu4496s34q6', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-07 08:56:02.424126'),
('ix0j23u5ds65tp49rrhzhf3rrp2ayn2k', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:29:59.709324'),
('j3z2icr2fi74lr9swt8oq3xbvxx0a5cv', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:14:33.993703'),
('jhzyryfgvvviiwrmz34vevhxxfyfpj1d', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-11 01:54:41.513171'),
('k2uddztpqog4kipts41tndo9owkn8af7', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-10 23:05:16.319172'),
('kmvgz3o5rioilblg3wwqur6im3o86ozb', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 04:51:24.185699'),
('ko7mvmbtj3tt39pcy9hg7l27dvfj21h7', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:28:05.671350'),
('kzhakshs3t1ks0d9r3h3qa7plsxkyuwj', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:30:11.007831'),
('l6zjj5grboiwadmdsr98lmf0ryn1a4p8', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:28:45.828260'),
('mlnbjat13hrgolefic8za87mpq271ga3', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 19:47:46.294384'),
('n1ksidqyjs1ojn327k9ixficft3jfjpq', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-06-16 06:34:28.934645'),
('n3hk15v3i4v5vtxkd5takriw0ln1yei4', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:32:08.020249'),
('npbcewt24ssfsgy5re407fv2hvsvkhe6', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:05:20.808965'),
('nqpnbnnbwtrt1plqgw5me8tw162qw6bg', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-05-04 18:54:58.265816'),
('nrbtckgzfon5yl65yp2nnvghzbjtgw5d', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-19 04:49:41.953863'),
('nuasrsi6kalukk6ot8uj1wlzcuj9qg8a', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:35:52.642609'),
('o4rv64adiy0olc6xlb77jinfzvut4olp', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-09 04:20:52.397983'),
('pezgbhr4pqyass4edmqhe4hgqphyl94x', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 13:50:51.058756'),
('pn30dgpr1dyvxpdziq7p8dav5gq8xqql', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:02:30.554228'),
('pwqlgtqlp8i2w2uav0oir40qs6mu8x1g', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-05 02:40:25.191997'),
('qmnqakzfrg49ye887g4ic3uwjc01gt9t', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:18:06.539177'),
('qsops7lej2cppuiaypoy1zo1en6n0umc', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-16 00:42:04.364950'),
('r1s8knzrl3bwdf7j3kityjvr27zqdkvb', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-25 00:16:46.504269'),
('rw7m078dt8bnggmqtb6kepytsrufvj3u', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2019-02-18 01:24:21.106950'),
('s2vtchd00l4hocj4loortqkagthfp3qg', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:40:08.345137'),
('sfe6vpnm4vv1oatm5nnh6l0vb93cs9bm', 'MjExMTY5YTQ3MGViM2I3NTI5MmQ1YWMxYjZmYjIzZmRiMDkwYzZlMTp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI0OGUyYzk3Njg0ZmUzNjQ4YmE1NGVhYzEyNTEwODI4OWZhM2I0OGMxIn0=', '2019-02-20 02:26:10.705346'),
('tdxgz5nug9hyawlcb3rh8hhnhqyrat43', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 19:46:13.587812'),
('v4bbru1ugu74x6oihr7sk3cpdk3q9v7g', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2019-02-17 23:58:57.924970'),
('vlugoy1p981fb3nxk2serk41onhsp199', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 05:45:57.261107'),
('wa7fjgv2og19w50m1ks7plh7cw3swj2n', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:00:43.880475'),
('xi764xzbb20hedqwt2jq2y0if3u8otdl', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 20:43:17.751521'),
('xqxbd573v0b1ikauesm824zhjf7zzwtm', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 19:50:35.934963'),
('yck1pt7iautzdlv9d8rdlwdsfzivaaqd', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:24:00.185875'),
('yxvzz148o4jyfofhwi2p5accm5yi2hjp', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-22 03:26:58.690648'),
('yxzljq9g20yh5fynbmr4ybsfutn3i80p', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 00:21:48.663705'),
('zeqa0stzqx95gactvjjzkkrtq6wff3eh', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:27:04.594284'),
('zrcdlv9wu3elsgkxfl573ygsr145boo7', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:24:10.834865');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `hoja_asistencia`
--

CREATE TABLE `hoja_asistencia` (
  `id_hoja_asistencia` int(11) NOT NULL,
  `id_asamblea` int(11) NOT NULL,
  `id_auth_user` int(11) NOT NULL,
  `estado` varchar(15) COLLATE hp8_bin NOT NULL,
  `hora` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `hoja_asistencia`
--

INSERT INTO `hoja_asistencia` (`id_hoja_asistencia`, `id_asamblea`, `id_auth_user`, `estado`, `hora`) VALUES
(5012, 62, 109, '3', '2019-08-03 01:30:42'),
(5013, 62, 110, '3', '2019-08-03 01:30:43'),
(5014, 62, 111, '3', '2019-08-03 01:30:43'),
(5015, 62, 113, '3', '2019-08-03 01:30:44'),
(5016, 62, 112, '3', '2019-08-03 01:30:44'),
(5017, 62, 114, '3', '2019-08-03 01:30:45'),
(5018, 62, 115, '3', '2019-08-03 01:30:45'),
(5019, 62, 35, '3', '2019-08-03 01:30:46'),
(5020, 62, 57, '3', '2019-08-03 01:30:46'),
(5021, 62, 116, '3', '2019-08-03 01:30:47'),
(5022, 62, 117, '1', '2000-12-12 12:00:00'),
(5023, 62, 108, '1', '2000-12-12 12:00:00'),
(5024, 62, 118, '1', '2000-12-12 12:00:00'),
(5025, 62, 119, '1', '2000-12-12 12:00:00'),
(5026, 62, 120, '1', '2000-12-12 12:00:00'),
(5027, 62, 121, '1', '2000-12-12 12:00:00'),
(5028, 62, 122, '1', '2000-12-12 12:00:00'),
(5029, 62, 123, '1', '2000-12-12 12:00:00'),
(5030, 62, 124, '1', '2000-12-12 12:00:00'),
(5031, 62, 125, '1', '2000-12-12 12:00:00'),
(5032, 62, 126, '1', '2000-12-12 12:00:00'),
(5033, 62, 127, '1', '2000-12-12 12:00:00'),
(5034, 62, 128, '1', '2000-12-12 12:00:00'),
(5035, 62, 129, '1', '2000-12-12 12:00:00'),
(5036, 62, 130, '1', '2000-12-12 12:00:00'),
(5037, 62, 131, '1', '2000-12-12 12:00:00'),
(5038, 62, 132, '1', '2000-12-12 12:00:00'),
(5039, 62, 133, '1', '2000-12-12 12:00:00'),
(5040, 62, 134, '1', '2000-12-12 12:00:00'),
(5041, 62, 135, '1', '2000-12-12 12:00:00'),
(5042, 62, 136, '1', '2000-12-12 12:00:00'),
(5043, 62, 137, '1', '2000-12-12 12:00:00'),
(5044, 62, 138, '1', '2000-12-12 12:00:00'),
(5045, 62, 139, '1', '2000-12-12 12:00:00'),
(5046, 62, 91, '1', '2000-12-12 12:00:00'),
(5047, 62, 140, '1', '2000-12-12 12:00:00'),
(5048, 62, 141, '1', '2000-12-12 12:00:00'),
(5049, 62, 142, '1', '2000-12-12 12:00:00'),
(5050, 62, 143, '1', '2000-12-12 12:00:00'),
(5051, 62, 144, '1', '2000-12-12 12:00:00'),
(5052, 62, 145, '1', '2000-12-12 12:00:00'),
(5053, 62, 146, '1', '2000-12-12 12:00:00'),
(5054, 62, 147, '1', '2000-12-12 12:00:00'),
(5055, 62, 148, '1', '2000-12-12 12:00:00'),
(5056, 62, 149, '3', '2000-12-12 12:00:00'),
(5057, 62, 46, '1', '2000-12-12 12:00:00'),
(5058, 62, 150, '1', '2000-12-12 12:00:00'),
(5059, 62, 151, '1', '2000-12-12 12:00:00'),
(5060, 62, 152, '1', '2000-12-12 12:00:00'),
(5061, 62, 105, '2', '2000-12-12 12:00:00'),
(5062, 62, 153, '1', '2000-12-12 12:00:00'),
(5063, 62, 154, '1', '2000-12-12 12:00:00'),
(5064, 62, 155, '1', '2000-12-12 12:00:00'),
(5065, 62, 156, '1', '2000-12-12 12:00:00'),
(5066, 62, 157, '1', '2000-12-12 12:00:00'),
(5185, 65, 109, '3', '2000-12-12 12:00:00'),
(5186, 65, 110, '1', '2000-12-12 12:00:00'),
(5187, 65, 111, '1', '2000-12-12 12:00:00'),
(5188, 65, 113, '1', '2000-12-12 12:00:00'),
(5189, 65, 112, '1', '2000-12-12 12:00:00'),
(5190, 65, 114, '1', '2000-12-12 12:00:00'),
(5191, 65, 115, '1', '2000-12-12 12:00:00'),
(5192, 65, 35, '1', '2000-12-12 12:00:00'),
(5193, 65, 57, '1', '2000-12-12 12:00:00'),
(5194, 65, 116, '1', '2000-12-12 12:00:00'),
(5195, 65, 117, '1', '2000-12-12 12:00:00'),
(5196, 65, 108, '1', '2000-12-12 12:00:00'),
(5197, 65, 118, '1', '2000-12-12 12:00:00'),
(5198, 65, 119, '1', '2000-12-12 12:00:00'),
(5199, 65, 120, '1', '2000-12-12 12:00:00'),
(5200, 65, 121, '1', '2000-12-12 12:00:00'),
(5201, 65, 122, '1', '2000-12-12 12:00:00'),
(5202, 65, 123, '1', '2000-12-12 12:00:00'),
(5203, 65, 124, '1', '2000-12-12 12:00:00'),
(5204, 65, 125, '1', '2000-12-12 12:00:00'),
(5205, 65, 126, '1', '2000-12-12 12:00:00'),
(5206, 65, 127, '1', '2000-12-12 12:00:00'),
(5207, 65, 128, '1', '2000-12-12 12:00:00'),
(5208, 65, 129, '1', '2000-12-12 12:00:00'),
(5209, 65, 130, '1', '2000-12-12 12:00:00'),
(5210, 65, 131, '1', '2000-12-12 12:00:00'),
(5211, 65, 132, '1', '2000-12-12 12:00:00'),
(5212, 65, 133, '1', '2000-12-12 12:00:00'),
(5213, 65, 134, '1', '2000-12-12 12:00:00'),
(5214, 65, 135, '1', '2000-12-12 12:00:00'),
(5215, 65, 136, '1', '2000-12-12 12:00:00'),
(5216, 65, 137, '1', '2000-12-12 12:00:00'),
(5217, 65, 138, '1', '2000-12-12 12:00:00'),
(5218, 65, 139, '1', '2000-12-12 12:00:00'),
(5219, 65, 91, '1', '2000-12-12 12:00:00'),
(5220, 65, 140, '1', '2000-12-12 12:00:00'),
(5221, 65, 141, '1', '2000-12-12 12:00:00'),
(5222, 65, 142, '1', '2000-12-12 12:00:00'),
(5223, 65, 143, '1', '2000-12-12 12:00:00'),
(5224, 65, 144, '1', '2000-12-12 12:00:00'),
(5225, 65, 145, '1', '2000-12-12 12:00:00'),
(5226, 65, 146, '1', '2000-12-12 12:00:00'),
(5227, 65, 147, '1', '2000-12-12 12:00:00'),
(5228, 65, 148, '1', '2000-12-12 12:00:00'),
(5229, 65, 149, '1', '2000-12-12 12:00:00'),
(5230, 65, 46, '1', '2000-12-12 12:00:00'),
(5231, 65, 150, '1', '2000-12-12 12:00:00'),
(5232, 65, 151, '1', '2000-12-12 12:00:00'),
(5233, 65, 152, '1', '2000-12-12 12:00:00'),
(5234, 65, 105, '1', '2000-12-12 12:00:00'),
(5235, 65, 153, '1', '2000-12-12 12:00:00'),
(5236, 65, 154, '1', '2000-12-12 12:00:00'),
(5237, 65, 155, '1', '2000-12-12 12:00:00'),
(5238, 65, 156, '1', '2000-12-12 12:00:00'),
(5239, 65, 157, '1', '2000-12-12 12:00:00'),
(5289, 68, 158, '1', '2019-08-03 01:05:36'),
(5290, 68, 125, '2', '2019-08-03 01:20:03'),
(5291, 68, 108, '1', '2019-08-03 06:14:25'),
(5292, 68, 159, '3', '2019-08-03 06:14:32'),
(5293, 68, 160, '2', '2019-08-03 06:16:18'),
(5294, 68, 148, '2', '2019-08-03 06:06:16'),
(5295, 68, 142, '3', '2019-08-03 06:06:19'),
(5296, 68, 149, '3', '2019-08-03 06:06:20'),
(5297, 68, 32, '1', '2019-08-03 06:06:21'),
(5298, 68, 161, '1', '2019-08-03 01:01:04'),
(5299, 68, 162, '3', '2019-08-03 01:03:02'),
(5300, 68, 155, '1', '2019-08-03 01:03:05'),
(5301, 68, 153, '2', '2019-08-03 01:01:09'),
(5302, 69, 6, '1', '2000-12-12 12:00:00'),
(5303, 69, 7, '1', '2000-12-12 12:00:00'),
(5304, 69, 8, '1', '2000-12-12 12:00:00'),
(5305, 69, 9, '1', '2000-12-12 12:00:00'),
(5306, 69, 10, '1', '2000-12-12 12:00:00'),
(5307, 69, 11, '3', '2000-12-12 12:00:00'),
(5308, 69, 12, '2', '2000-12-12 12:00:00'),
(5309, 69, 13, '1', '2000-12-12 12:00:00'),
(5310, 69, 14, '0', '2000-12-12 12:00:00'),
(5311, 69, 15, '0', '2000-12-12 12:00:00'),
(5312, 69, 16, '0', '2000-12-12 12:00:00'),
(5313, 69, 17, '0', '2000-12-12 12:00:00'),
(5314, 69, 18, '0', '2000-12-12 12:00:00'),
(5315, 69, 19, '0', '2000-12-12 12:00:00'),
(5316, 69, 20, '0', '2000-12-12 12:00:00'),
(5317, 69, 21, '0', '2000-12-12 12:00:00'),
(5318, 69, 22, '0', '2000-12-12 12:00:00'),
(5319, 69, 35, '0', '2000-12-12 12:00:00'),
(5320, 69, 23, '0', '2000-12-12 12:00:00'),
(5321, 69, 24, '0', '2000-12-12 12:00:00'),
(5322, 69, 25, '0', '2000-12-12 12:00:00'),
(5323, 69, 26, '0', '2000-12-12 12:00:00'),
(5324, 69, 27, '0', '2000-12-12 12:00:00'),
(5325, 69, 28, '0', '2000-12-12 12:00:00'),
(5326, 69, 29, '0', '2000-12-12 12:00:00'),
(5327, 69, 30, '0', '2000-12-12 12:00:00'),
(5328, 69, 31, '0', '2000-12-12 12:00:00'),
(5329, 69, 32, '0', '2000-12-12 12:00:00'),
(5330, 69, 33, '0', '2000-12-12 12:00:00'),
(5331, 69, 34, '0', '2000-12-12 12:00:00'),
(5332, 69, 36, '0', '2000-12-12 12:00:00'),
(5333, 69, 37, '0', '2000-12-12 12:00:00'),
(5334, 69, 38, '0', '2000-12-12 12:00:00'),
(5335, 69, 39, '0', '2000-12-12 12:00:00'),
(5336, 69, 40, '0', '2000-12-12 12:00:00'),
(5337, 69, 41, '0', '2000-12-12 12:00:00'),
(5338, 69, 42, '0', '2000-12-12 12:00:00'),
(5339, 69, 43, '0', '2000-12-12 12:00:00'),
(5340, 69, 44, '0', '2000-12-12 12:00:00'),
(5341, 69, 45, '0', '2000-12-12 12:00:00'),
(5342, 69, 46, '0', '2000-12-12 12:00:00'),
(5343, 69, 47, '0', '2000-12-12 12:00:00'),
(5344, 69, 48, '0', '2000-12-12 12:00:00'),
(5345, 69, 49, '0', '2000-12-12 12:00:00'),
(5346, 69, 50, '0', '2000-12-12 12:00:00'),
(5347, 69, 51, '0', '2000-12-12 12:00:00'),
(5348, 69, 52, '0', '2000-12-12 12:00:00'),
(5349, 69, 53, '0', '2000-12-12 12:00:00'),
(5350, 69, 54, '0', '2000-12-12 12:00:00'),
(5351, 69, 55, '0', '2000-12-12 12:00:00'),
(5352, 69, 56, '0', '2000-12-12 12:00:00'),
(5353, 69, 57, '0', '2000-12-12 12:00:00'),
(5354, 69, 58, '0', '2000-12-12 12:00:00'),
(5355, 69, 59, '0', '2000-12-12 12:00:00'),
(5356, 69, 60, '0', '2000-12-12 12:00:00'),
(5357, 69, 5, '0', '2000-12-12 12:00:00'),
(5358, 69, 61, '0', '2000-12-12 12:00:00'),
(5359, 69, 62, '0', '2000-12-12 12:00:00'),
(5360, 69, 63, '0', '2000-12-12 12:00:00'),
(5361, 69, 64, '0', '2000-12-12 12:00:00'),
(5362, 69, 65, '0', '2000-12-12 12:00:00'),
(5363, 69, 66, '0', '2000-12-12 12:00:00'),
(5364, 69, 67, '0', '2000-12-12 12:00:00'),
(5365, 69, 68, '0', '2000-12-12 12:00:00'),
(5366, 69, 69, '0', '2000-12-12 12:00:00'),
(5367, 69, 70, '0', '2000-12-12 12:00:00'),
(5368, 69, 71, '0', '2000-12-12 12:00:00'),
(5369, 69, 72, '0', '2000-12-12 12:00:00'),
(5370, 69, 73, '0', '2000-12-12 12:00:00'),
(5371, 69, 74, '0', '2000-12-12 12:00:00'),
(5372, 69, 75, '0', '2000-12-12 12:00:00'),
(5373, 69, 76, '0', '2000-12-12 12:00:00'),
(5374, 69, 77, '0', '2000-12-12 12:00:00'),
(5375, 69, 78, '0', '2000-12-12 12:00:00'),
(5376, 69, 79, '0', '2000-12-12 12:00:00'),
(5377, 69, 80, '0', '2000-12-12 12:00:00'),
(5378, 69, 81, '0', '2000-12-12 12:00:00'),
(5379, 69, 82, '0', '2000-12-12 12:00:00'),
(5380, 69, 2, '0', '2000-12-12 12:00:00'),
(5381, 69, 83, '0', '2000-12-12 12:00:00'),
(5382, 69, 84, '0', '2000-12-12 12:00:00'),
(5383, 69, 85, '0', '2000-12-12 12:00:00'),
(5384, 69, 86, '0', '2000-12-12 12:00:00'),
(5385, 69, 87, '0', '2000-12-12 12:00:00'),
(5386, 69, 88, '0', '2000-12-12 12:00:00'),
(5387, 69, 89, '0', '2000-12-12 12:00:00'),
(5388, 69, 90, '0', '2000-12-12 12:00:00'),
(5389, 69, 91, '0', '2000-12-12 12:00:00'),
(5390, 69, 92, '0', '2000-12-12 12:00:00'),
(5391, 69, 93, '0', '2000-12-12 12:00:00'),
(5392, 69, 94, '0', '2000-12-12 12:00:00'),
(5393, 69, 95, '0', '2000-12-12 12:00:00'),
(5394, 69, 96, '0', '2000-12-12 12:00:00'),
(5395, 69, 97, '0', '2000-12-12 12:00:00'),
(5396, 69, 98, '0', '2000-12-12 12:00:00'),
(5397, 69, 99, '0', '2000-12-12 12:00:00'),
(5398, 69, 100, '0', '2000-12-12 12:00:00'),
(5399, 69, 101, '0', '2000-12-12 12:00:00'),
(5400, 69, 102, '0', '2000-12-12 12:00:00'),
(5401, 69, 103, '0', '2000-12-12 12:00:00'),
(5402, 69, 104, '0', '2000-12-12 12:00:00'),
(5403, 69, 105, '0', '2000-12-12 12:00:00'),
(5404, 69, 106, '0', '2000-12-12 12:00:00'),
(5405, 69, 107, '0', '2000-12-12 12:00:00'),
(5406, 69, 108, '0', '2000-12-12 12:00:00'),
(5407, 69, 109, '0', '2000-12-12 12:00:00'),
(5408, 69, 110, '0', '2000-12-12 12:00:00'),
(5409, 69, 111, '0', '2000-12-12 12:00:00'),
(5410, 69, 113, '0', '2000-12-12 12:00:00'),
(5411, 69, 112, '0', '2000-12-12 12:00:00'),
(5412, 69, 114, '0', '2000-12-12 12:00:00'),
(5413, 69, 115, '0', '2000-12-12 12:00:00'),
(5414, 69, 116, '0', '2000-12-12 12:00:00'),
(5415, 69, 117, '0', '2000-12-12 12:00:00'),
(5416, 69, 118, '0', '2000-12-12 12:00:00'),
(5417, 69, 119, '0', '2000-12-12 12:00:00'),
(5418, 69, 120, '0', '2000-12-12 12:00:00'),
(5419, 69, 121, '0', '2000-12-12 12:00:00'),
(5420, 69, 122, '0', '2000-12-12 12:00:00'),
(5421, 69, 123, '0', '2000-12-12 12:00:00'),
(5422, 69, 124, '0', '2000-12-12 12:00:00'),
(5423, 69, 125, '0', '2000-12-12 12:00:00'),
(5424, 69, 126, '0', '2000-12-12 12:00:00'),
(5425, 69, 127, '0', '2000-12-12 12:00:00'),
(5426, 69, 128, '0', '2000-12-12 12:00:00'),
(5427, 69, 129, '0', '2000-12-12 12:00:00'),
(5428, 69, 130, '0', '2000-12-12 12:00:00'),
(5429, 69, 131, '0', '2000-12-12 12:00:00'),
(5430, 69, 132, '0', '2000-12-12 12:00:00'),
(5431, 69, 133, '0', '2000-12-12 12:00:00'),
(5432, 69, 134, '0', '2000-12-12 12:00:00'),
(5433, 69, 135, '0', '2000-12-12 12:00:00'),
(5434, 69, 136, '0', '2000-12-12 12:00:00'),
(5435, 69, 137, '0', '2000-12-12 12:00:00'),
(5436, 69, 138, '0', '2000-12-12 12:00:00'),
(5437, 69, 139, '0', '2000-12-12 12:00:00'),
(5438, 69, 140, '0', '2000-12-12 12:00:00'),
(5439, 69, 141, '0', '2000-12-12 12:00:00'),
(5440, 69, 142, '0', '2000-12-12 12:00:00'),
(5441, 69, 143, '0', '2000-12-12 12:00:00'),
(5442, 69, 144, '0', '2000-12-12 12:00:00'),
(5443, 69, 145, '0', '2000-12-12 12:00:00'),
(5444, 69, 146, '0', '2000-12-12 12:00:00'),
(5445, 69, 147, '0', '2000-12-12 12:00:00'),
(5446, 69, 148, '0', '2000-12-12 12:00:00'),
(5447, 69, 149, '0', '2000-12-12 12:00:00'),
(5448, 69, 150, '0', '2000-12-12 12:00:00'),
(5449, 69, 151, '0', '2000-12-12 12:00:00'),
(5450, 69, 152, '0', '2000-12-12 12:00:00'),
(5451, 69, 153, '0', '2000-12-12 12:00:00'),
(5452, 69, 154, '0', '2000-12-12 12:00:00'),
(5453, 69, 155, '0', '2000-12-12 12:00:00'),
(5454, 69, 156, '0', '2000-12-12 12:00:00'),
(5455, 69, 157, '0', '2000-12-12 12:00:00'),
(5456, 69, 158, '0', '2000-12-12 12:00:00'),
(5457, 69, 159, '0', '2000-12-12 12:00:00'),
(5458, 69, 160, '0', '2000-12-12 12:00:00'),
(5459, 69, 161, '0', '2000-12-12 12:00:00'),
(5460, 69, 162, '0', '2000-12-12 12:00:00'),
(5461, 69, 165, '0', '2000-12-12 12:00:00'),
(5462, 69, 166, '0', '2000-12-12 12:00:00'),
(5463, 69, 167, '0', '2000-12-12 12:00:00'),
(5464, 69, 168, '0', '2000-12-12 12:00:00'),
(5465, 69, 169, '0', '2000-12-12 12:00:00'),
(5466, 69, 170, '0', '2000-12-12 12:00:00'),
(5467, 69, 171, '0', '2000-12-12 12:00:00'),
(5468, 69, 172, '0', '2000-12-12 12:00:00'),
(5469, 69, 173, '0', '2000-12-12 12:00:00'),
(5470, 69, 174, '0', '2000-12-12 12:00:00'),
(5471, 69, 175, '0', '2000-12-12 12:00:00'),
(5472, 69, 176, '0', '2000-12-12 12:00:00'),
(5473, 69, 177, '0', '2000-12-12 12:00:00'),
(5474, 69, 178, '0', '2000-12-12 12:00:00'),
(5475, 69, 179, '0', '2000-12-12 12:00:00'),
(5476, 69, 180, '0', '2000-12-12 12:00:00'),
(5477, 69, 181, '0', '2000-12-12 12:00:00'),
(5478, 69, 182, '0', '2000-12-12 12:00:00'),
(5479, 69, 183, '0', '2000-12-12 12:00:00'),
(5480, 69, 184, '0', '2000-12-12 12:00:00'),
(5481, 69, 185, '0', '2000-12-12 12:00:00'),
(5482, 69, 186, '0', '2000-12-12 12:00:00'),
(5483, 69, 187, '0', '2000-12-12 12:00:00'),
(5484, 69, 188, '0', '2000-12-12 12:00:00'),
(5485, 69, 189, '0', '2000-12-12 12:00:00'),
(5486, 69, 190, '0', '2000-12-12 12:00:00'),
(5487, 69, 191, '0', '2000-12-12 12:00:00'),
(5488, 69, 192, '0', '2000-12-12 12:00:00'),
(5489, 69, 193, '0', '2000-12-12 12:00:00'),
(5490, 69, 194, '0', '2000-12-12 12:00:00'),
(5504, 71, 6, '1', '2019-08-04 13:00:52'),
(5505, 71, 7, '3', '2000-12-12 12:00:00'),
(5506, 71, 8, '3', '2000-12-12 12:00:00'),
(5507, 71, 9, '1', '2019-08-03 02:06:05'),
(5508, 71, 10, '1', '2019-08-03 02:06:21'),
(5509, 71, 11, '1', '2019-08-03 02:39:07'),
(5510, 71, 12, '2', '2019-08-03 02:38:20'),
(5511, 71, 13, '2', '2019-08-03 02:38:45'),
(5512, 71, 14, '1', '2019-08-04 13:03:25'),
(5513, 71, 15, '2', '2019-08-03 02:40:16'),
(5514, 71, 16, '3', '2019-08-03 02:39:57'),
(5515, 71, 17, '1', '2019-08-03 02:41:41'),
(5516, 71, 18, '0', '2000-12-12 12:00:00'),
(5517, 71, 19, '0', '2000-12-12 12:00:00'),
(5518, 71, 20, '0', '2000-12-12 12:00:00'),
(5519, 71, 21, '0', '2000-12-12 12:00:00'),
(5520, 71, 22, '0', '2000-12-12 12:00:00'),
(5521, 71, 35, '0', '2000-12-12 12:00:00'),
(5522, 71, 23, '0', '2000-12-12 12:00:00'),
(5523, 71, 24, '0', '2000-12-12 12:00:00'),
(5524, 71, 25, '0', '2000-12-12 12:00:00'),
(5525, 71, 26, '0', '2000-12-12 12:00:00'),
(5526, 71, 27, '0', '2000-12-12 12:00:00'),
(5527, 71, 28, '0', '2000-12-12 12:00:00'),
(5528, 71, 29, '0', '2000-12-12 12:00:00'),
(5529, 71, 30, '0', '2000-12-12 12:00:00'),
(5530, 71, 31, '0', '2000-12-12 12:00:00'),
(5531, 71, 32, '0', '2000-12-12 12:00:00'),
(5532, 71, 33, '0', '2000-12-12 12:00:00'),
(5533, 71, 34, '0', '2000-12-12 12:00:00'),
(5534, 71, 36, '0', '2000-12-12 12:00:00'),
(5535, 71, 37, '0', '2000-12-12 12:00:00'),
(5536, 71, 38, '0', '2000-12-12 12:00:00'),
(5537, 71, 39, '0', '2000-12-12 12:00:00'),
(5538, 71, 40, '0', '2000-12-12 12:00:00'),
(5539, 71, 41, '0', '2000-12-12 12:00:00'),
(5540, 71, 42, '0', '2000-12-12 12:00:00'),
(5541, 71, 43, '0', '2000-12-12 12:00:00'),
(5542, 71, 44, '0', '2000-12-12 12:00:00'),
(5543, 71, 45, '0', '2000-12-12 12:00:00'),
(5544, 71, 46, '0', '2000-12-12 12:00:00'),
(5545, 71, 47, '0', '2000-12-12 12:00:00'),
(5546, 71, 48, '0', '2000-12-12 12:00:00'),
(5547, 71, 49, '0', '2000-12-12 12:00:00'),
(5548, 71, 50, '0', '2000-12-12 12:00:00'),
(5549, 71, 51, '0', '2000-12-12 12:00:00'),
(5550, 71, 52, '0', '2000-12-12 12:00:00'),
(5551, 71, 53, '0', '2000-12-12 12:00:00'),
(5552, 71, 54, '0', '2000-12-12 12:00:00'),
(5553, 71, 55, '0', '2000-12-12 12:00:00'),
(5554, 71, 56, '0', '2000-12-12 12:00:00'),
(5555, 71, 57, '0', '2000-12-12 12:00:00'),
(5556, 71, 58, '0', '2000-12-12 12:00:00'),
(5557, 71, 59, '0', '2000-12-12 12:00:00'),
(5558, 71, 60, '0', '2000-12-12 12:00:00'),
(5559, 71, 5, '0', '2000-12-12 12:00:00'),
(5560, 71, 61, '0', '2000-12-12 12:00:00'),
(5561, 71, 62, '0', '2000-12-12 12:00:00'),
(5562, 71, 63, '0', '2000-12-12 12:00:00'),
(5563, 71, 64, '0', '2000-12-12 12:00:00'),
(5564, 71, 65, '0', '2000-12-12 12:00:00'),
(5565, 71, 66, '0', '2000-12-12 12:00:00'),
(5566, 71, 67, '0', '2000-12-12 12:00:00'),
(5567, 71, 68, '0', '2000-12-12 12:00:00'),
(5568, 71, 69, '0', '2000-12-12 12:00:00'),
(5569, 71, 70, '0', '2000-12-12 12:00:00'),
(5570, 71, 71, '0', '2000-12-12 12:00:00'),
(5571, 71, 72, '0', '2000-12-12 12:00:00'),
(5572, 71, 73, '0', '2000-12-12 12:00:00'),
(5573, 71, 74, '0', '2000-12-12 12:00:00'),
(5574, 71, 75, '0', '2000-12-12 12:00:00'),
(5575, 71, 76, '2', '2019-08-03 02:44:30'),
(5576, 71, 77, '0', '2000-12-12 12:00:00'),
(5577, 71, 78, '0', '2000-12-12 12:00:00'),
(5578, 71, 79, '0', '2000-12-12 12:00:00'),
(5579, 71, 80, '0', '2000-12-12 12:00:00'),
(5580, 71, 81, '0', '2000-12-12 12:00:00'),
(5581, 71, 82, '0', '2000-12-12 12:00:00'),
(5582, 71, 2, '0', '2000-12-12 12:00:00'),
(5583, 71, 83, '0', '2000-12-12 12:00:00'),
(5584, 71, 84, '0', '2000-12-12 12:00:00'),
(5585, 71, 85, '0', '2000-12-12 12:00:00'),
(5586, 71, 86, '0', '2000-12-12 12:00:00'),
(5587, 71, 87, '0', '2000-12-12 12:00:00'),
(5588, 71, 88, '0', '2000-12-12 12:00:00'),
(5589, 71, 89, '0', '2000-12-12 12:00:00'),
(5590, 71, 90, '0', '2000-12-12 12:00:00'),
(5591, 71, 91, '0', '2000-12-12 12:00:00'),
(5592, 71, 92, '0', '2000-12-12 12:00:00'),
(5593, 71, 93, '0', '2000-12-12 12:00:00'),
(5594, 71, 94, '0', '2000-12-12 12:00:00'),
(5595, 71, 95, '0', '2000-12-12 12:00:00'),
(5596, 71, 96, '0', '2000-12-12 12:00:00'),
(5597, 71, 97, '0', '2000-12-12 12:00:00'),
(5598, 71, 98, '0', '2000-12-12 12:00:00'),
(5599, 71, 99, '0', '2000-12-12 12:00:00'),
(5600, 71, 100, '0', '2000-12-12 12:00:00'),
(5601, 71, 101, '0', '2000-12-12 12:00:00'),
(5602, 71, 102, '0', '2000-12-12 12:00:00'),
(5603, 71, 103, '0', '2000-12-12 12:00:00'),
(5604, 71, 104, '0', '2000-12-12 12:00:00'),
(5605, 71, 105, '0', '2000-12-12 12:00:00'),
(5606, 71, 106, '0', '2000-12-12 12:00:00'),
(5607, 71, 107, '0', '2000-12-12 12:00:00'),
(5608, 71, 108, '0', '2000-12-12 12:00:00'),
(5609, 71, 109, '0', '2000-12-12 12:00:00'),
(5610, 71, 110, '0', '2000-12-12 12:00:00'),
(5611, 71, 111, '0', '2000-12-12 12:00:00'),
(5612, 71, 113, '0', '2000-12-12 12:00:00'),
(5613, 71, 112, '0', '2000-12-12 12:00:00'),
(5614, 71, 114, '0', '2000-12-12 12:00:00'),
(5615, 71, 115, '0', '2000-12-12 12:00:00'),
(5616, 71, 116, '0', '2000-12-12 12:00:00'),
(5617, 71, 117, '0', '2000-12-12 12:00:00'),
(5618, 71, 118, '0', '2000-12-12 12:00:00'),
(5619, 71, 119, '0', '2000-12-12 12:00:00'),
(5620, 71, 120, '0', '2000-12-12 12:00:00'),
(5621, 71, 121, '0', '2000-12-12 12:00:00'),
(5622, 71, 122, '0', '2000-12-12 12:00:00'),
(5623, 71, 123, '0', '2000-12-12 12:00:00'),
(5624, 71, 124, '0', '2000-12-12 12:00:00'),
(5625, 71, 125, '0', '2000-12-12 12:00:00'),
(5626, 71, 126, '0', '2000-12-12 12:00:00'),
(5627, 71, 127, '0', '2000-12-12 12:00:00'),
(5628, 71, 128, '0', '2000-12-12 12:00:00'),
(5629, 71, 129, '0', '2000-12-12 12:00:00'),
(5630, 71, 130, '0', '2000-12-12 12:00:00'),
(5631, 71, 131, '0', '2000-12-12 12:00:00'),
(5632, 71, 132, '0', '2000-12-12 12:00:00'),
(5633, 71, 133, '0', '2000-12-12 12:00:00'),
(5634, 71, 134, '0', '2000-12-12 12:00:00'),
(5635, 71, 135, '0', '2000-12-12 12:00:00'),
(5636, 71, 136, '0', '2000-12-12 12:00:00'),
(5637, 71, 137, '0', '2000-12-12 12:00:00'),
(5638, 71, 138, '0', '2000-12-12 12:00:00'),
(5639, 71, 139, '0', '2000-12-12 12:00:00'),
(5640, 71, 140, '0', '2000-12-12 12:00:00'),
(5641, 71, 141, '0', '2000-12-12 12:00:00'),
(5642, 71, 142, '0', '2000-12-12 12:00:00'),
(5643, 71, 143, '0', '2000-12-12 12:00:00'),
(5644, 71, 144, '0', '2000-12-12 12:00:00'),
(5645, 71, 145, '0', '2000-12-12 12:00:00'),
(5646, 71, 146, '0', '2000-12-12 12:00:00'),
(5647, 71, 147, '0', '2000-12-12 12:00:00'),
(5648, 71, 148, '0', '2000-12-12 12:00:00'),
(5649, 71, 149, '0', '2000-12-12 12:00:00'),
(5650, 71, 150, '0', '2000-12-12 12:00:00'),
(5651, 71, 151, '0', '2000-12-12 12:00:00'),
(5652, 71, 152, '0', '2000-12-12 12:00:00'),
(5653, 71, 153, '0', '2000-12-12 12:00:00'),
(5654, 71, 154, '0', '2000-12-12 12:00:00'),
(5655, 71, 155, '0', '2000-12-12 12:00:00'),
(5656, 71, 156, '0', '2000-12-12 12:00:00'),
(5657, 71, 157, '0', '2000-12-12 12:00:00'),
(5658, 71, 158, '0', '2000-12-12 12:00:00'),
(5659, 71, 159, '0', '2000-12-12 12:00:00'),
(5660, 71, 160, '0', '2000-12-12 12:00:00'),
(5661, 71, 161, '0', '2000-12-12 12:00:00'),
(5662, 71, 162, '0', '2000-12-12 12:00:00'),
(5663, 71, 165, '0', '2000-12-12 12:00:00'),
(5664, 71, 166, '0', '2000-12-12 12:00:00'),
(5665, 71, 167, '0', '2000-12-12 12:00:00'),
(5666, 71, 168, '0', '2000-12-12 12:00:00'),
(5667, 71, 169, '0', '2000-12-12 12:00:00'),
(5668, 71, 170, '0', '2000-12-12 12:00:00'),
(5669, 71, 171, '0', '2000-12-12 12:00:00'),
(5670, 71, 172, '0', '2000-12-12 12:00:00'),
(5671, 71, 173, '0', '2000-12-12 12:00:00'),
(5672, 71, 174, '0', '2000-12-12 12:00:00'),
(5673, 71, 175, '0', '2000-12-12 12:00:00'),
(5674, 71, 176, '0', '2000-12-12 12:00:00'),
(5675, 71, 177, '0', '2000-12-12 12:00:00'),
(5676, 71, 178, '0', '2000-12-12 12:00:00'),
(5677, 71, 179, '0', '2000-12-12 12:00:00'),
(5678, 71, 180, '0', '2000-12-12 12:00:00'),
(5679, 71, 181, '0', '2000-12-12 12:00:00'),
(5680, 71, 182, '0', '2000-12-12 12:00:00'),
(5681, 71, 183, '0', '2000-12-12 12:00:00'),
(5682, 71, 184, '0', '2000-12-12 12:00:00'),
(5683, 71, 185, '0', '2000-12-12 12:00:00'),
(5684, 71, 186, '0', '2000-12-12 12:00:00'),
(5685, 71, 187, '0', '2000-12-12 12:00:00'),
(5686, 71, 188, '0', '2000-12-12 12:00:00'),
(5687, 71, 189, '0', '2000-12-12 12:00:00'),
(5688, 71, 190, '0', '2000-12-12 12:00:00'),
(5689, 71, 191, '0', '2000-12-12 12:00:00'),
(5690, 71, 192, '0', '2000-12-12 12:00:00'),
(5691, 71, 193, '0', '2000-12-12 12:00:00'),
(5692, 71, 194, '0', '2000-12-12 12:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `limpieza`
--

CREATE TABLE `limpieza` (
  `id_limpieza` int(11) NOT NULL,
  `decripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(1) COLLATE hp8_bin DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `fecha_limpieza` date DEFAULT NULL,
  `fecha_revision` datetime DEFAULT NULL,
  `hora_revision` time NOT NULL,
  `estado` varchar(1) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `limpieza`
--

INSERT INTO `limpieza` (`id_limpieza`, `decripcion`, `tipo`, `fecha_registro`, `fecha_limpieza`, `fecha_revision`, `hora_revision`, `estado`) VALUES
(1, 'Prueba1', '0', NULL, NULL, NULL, '12:30:00', '1'),
(2, 'Prueba 1', '1', NULL, '2019-08-11', '2019-08-12 00:00:00', '16:30:00', '0'),
(3, 'Datatime', '0', '2019-08-10', '2019-08-11', '2019-08-11 00:00:00', '12:30:00', '0');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista`
--

CREATE TABLE `lista` (
  `id_lista` int(11) NOT NULL,
  `id_comite` int(11) DEFAULT NULL,
  `nombre_lista` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `estado` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_termino` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa`
--

CREATE TABLE `multa` (
  `id_multa` int(11) NOT NULL,
  `concepto` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `estado` varchar(1) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa_asistencia`
--

CREATE TABLE `multa_asistencia` (
  `id_multa_asistencia` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL,
  `id_hoja_asistencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa_limpia`
--

CREATE TABLE `multa_limpia` (
  `id_multa_limpia` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL,
  `id_det_limpia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa_orden`
--

CREATE TABLE `multa_orden` (
  `id_multa_orden` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `noticia`
--

CREATE TABLE `noticia` (
  `id_noticia` int(11) NOT NULL,
  `titular` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `descripcion` varchar(400) COLLATE hp8_bin DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `noticia`
--

INSERT INTO `noticia` (`id_noticia`, `titular`, `descripcion`, `fecha`, `foto`) VALUES
(1, 'Titulación Gratuita', 'La ONG Sedepas Norte brindará una campaña de titulación gratuita para toso los usuarios del comité de regantes Nuevo Horizonte', '2018-10-24 00:00:00', 'photos/img006.jpg'),
(2, 'Tía Nilda', 'La sra Nilda Barrios donará un puente en el Ramal 3', '2018-10-28 00:00:00', 'photos/1.PNG'),
(3, 'aaaa', 'ccc', '2019-06-15 00:00:00', 'photos/20180511_211637.jpg');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `obra`
--

CREATE TABLE `obra` (
  `id_obra` int(11) NOT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `decripcion` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `monto` double DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_riego`
--

CREATE TABLE `orden_riego` (
  `id_orden_riego` int(11) NOT NULL,
  `id_reparto` int(11) DEFAULT NULL,
  `id_parcela` int(11) DEFAULT NULL,
  `fecha_establecida` date DEFAULT NULL,
  `fecha_inicio` datetime DEFAULT NULL,
  `duracion` double DEFAULT NULL,
  `unidad` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `cantidad_has` double DEFAULT NULL,
  `importe` double DEFAULT NULL,
  `estado` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `id_comprobante` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `orden_riego`
--

INSERT INTO `orden_riego` (`id_orden_riego`, `id_reparto`, `id_parcela`, `fecha_establecida`, `fecha_inicio`, `duracion`, `unidad`, `cantidad_has`, `importe`, `estado`, `id_comprobante`) VALUES
(1, 12, 1, '2019-08-17', '2019-08-17 02:02:00', 4.5, 'h', 4.5, 11.25, 'Entregada', NULL),
(2, 13, 3, '2019-08-17', '2019-08-17 12:17:00', 10, 'h', 10, 25, 'Aprobada', NULL),
(3, 13, 7, '2019-08-05', NULL, 3, 'h', 3, 7.5, 'Entregada', NULL),
(4, 14, 6, '2019-08-05', NULL, 2, 'h', 2, 5, 'Solicitada', NULL),
(5, 13, 5, '2019-08-05', NULL, 2.5, 'h', 2.5, 6.25, 'Aprobada', NULL),
(6, 13, 4, '2019-08-05', NULL, 3.5, 'h', 3.5, 8.75, 'Entregada', NULL),
(7, 13, 9, '2019-08-05', NULL, 1.5, 'h', 1.5, 3.75, 'Aprobada', NULL),
(8, 13, 60, '2019-08-05', NULL, 0.5, 'h', 0.5, 1.25, 'Aprobada', NULL),
(9, 13, 119, '2019-08-05', NULL, 1, 'h', 1, 2.5, 'Aprobada', NULL),
(10, 13, 8, '2019-08-07', NULL, 10, 'h', 10, 25, 'Aprobada', NULL),
(11, 14, 10, '2019-08-09', NULL, 15, 'h', 15, 37.5, 'Solicitada', NULL),
(12, 13, 96, '2019-08-09', NULL, 6, 'h', 6, 15, 'Solicitada', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `parcela`
--

CREATE TABLE `parcela` (
  `id_parcela` int(11) NOT NULL,
  `nombre` varchar(60) COLLATE hp8_bin DEFAULT NULL,
  `ubicacion` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `num_toma` int(11) DEFAULT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `id_auth_user` int(11) DEFAULT NULL,
  `total_has` double DEFAULT NULL,
  `has_sembradas` double DEFAULT NULL,
  `descripcion` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `codigo_predio` varchar(25) COLLATE hp8_bin NOT NULL,
  `volumen_agua` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `parcela`
--

INSERT INTO `parcela` (`id_parcela`, `nombre`, `ubicacion`, `num_toma`, `id_canal`, `id_auth_user`, `total_has`, `has_sembradas`, `descripcion`, `estado`, `codigo_predio`, `volumen_agua`) VALUES
(1, 'El Algarrobo', 'ramal 1', 1, 1, 6, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(2, 'Ramoncito A', 'ramal 1', 2, 1, 7, 0.54, 0.54, 'sin descripciµn', '1', 'null', 2484),
(3, 'Ramoncito B', 'ramal 1', 3, 1, 7, 0.44, 0.44, 'sin descripciµn', '1', 'null', 2024),
(4, 'Los Julios', 'ramal 1', 4, 1, 8, 3.66, 1, 'sin descripciµn', '1', 'null', 4600),
(5, 'El Guabo', 'ramal 1', 5, 1, 9, 1.75, 1, 'sin descripciµn', '1', 'null', 4600),
(6, 'El Puente', 'ramal 1', 6, 1, 10, 1.24, 1, 'sin descripciµn', '1', 'null', 4600),
(7, 'Los Girasoles', 'ramal 1', 7, 1, 11, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(8, 'Los Jardines', 'ramal 1', 8, 1, 12, 2.11, 1, 'sin descripciµn', '1', 'null', 4600),
(9, 'El Pozo', 'ramal 1', 9, 1, 13, 0.92, 0.92, 'sin descripciµn', '1', 'null', 4232),
(10, 'El Pozo', 'ramal 1', 10, 1, 14, 0.5, 0.5, 'sin descripciµn', '1', 'null', 1300),
(11, 'Naranja', 'ramal 1', 11, 1, 15, 1.32, 1.32, 'sin descripciµn', '1', 'null', 6072),
(12, 'La 63', 'ramal 1', 12, 1, 16, 0.99, 0.99, 'sin descripciµn', '1', 'null', 4554),
(13, 'Chilo', 'ramal 1', 13, 1, 17, 0.87, 0.87, 'sin descripciµn', '1', 'null', 4094),
(14, 'La 61', 'ramal 1', 14, 1, 18, 0.68, 0.68, 'sin descripciµn', '1', 'null', 3128),
(15, 'La Estrella', 'ramal 1', 15, 1, 19, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(16, 'El Eucalipto', 'ramal 1', 16, 1, 20, 2.63, 1, 'sin descripciµn', '1', 'null', 4600),
(17, 'El Limµn', 'ramal 1', 17, 1, 21, 2.44, 2, 'sin descripciµn', '1', 'null', 9200),
(18, 'El Pozo', 'ramal 1', 18, 1, 22, 0.81, 0.81, 'sin descripciµn', '1', 'null', 3726),
(19, 'Ana Myle 3', 'ramal 1', 19, 1, 35, 0.99, 0.99, 'sin descripciµn', '1', 'null', 4554),
(20, 'Alexandra', 'ramal 1', 20, 1, 23, 0.98, 0.98, 'sin descripciµn', '1', 'null', 4508),
(21, 'La Palmera', 'ramal 1', 21, 1, 24, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(22, 'La Caþa ', 'ramal 1', 22, 1, 25, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(23, 'El Huerto', 'ramal 1', 23, 1, 26, 1.03, 1.03, 'sin descripciµn', '1', 'null', 4738),
(24, 'Soledad', 'ramal 1', 24, 1, 27, 1.05, 1.05, 'sin descripciµn', '1', 'null', 4830),
(25, 'La Huerta', 'ramal 1', 25, 1, 28, 0.99, 0.99, 'sin descripciµn', '1', 'null', 4554),
(26, 'El Algarrobo', 'ramal 1', 26, 1, 29, 0.86, 0.86, 'sin descripciµn', '1', 'null', 3956),
(27, 'El Pino', 'ramal 1', 27, 1, 30, 1.01, 1.01, 'sin descripciµn', '1', 'null', 4646),
(28, 'MatÚas', 'ramal 1', 28, 1, 31, 1.94, 1.94, 'sin descripciµn', '1', 'null', 8924),
(29, 'El Limµn', 'ramal 1', 29, 1, 32, 0.96, 0.96, 'sin descripciµn', '1', 'null', 4416),
(30, 'La MaracuyÃ', 'ramal 1', 30, 1, 33, 0.94, 0.94, 'sin descripciµn', '1', 'null', 4324),
(31, 'La Tranca', 'ramal 1', 31, 1, 34, 1.02, 1.02, 'sin descripciµn', '1', 'null', 4692),
(32, 'Ana Myle 2', 'ramal 1', 32, 1, 35, 0.89, 0.89, 'sin descripciµn', '1', 'null', 4094),
(33, 'Noni', 'ramal 1', 33, 1, 36, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(34, 'Los Chilenos', 'ramal 1', 34, 1, 37, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(35, 'Los Huabitos', 'ramal 1', 35, 1, 38, 2.58, 1.5, 'sin descripciµn', '1', 'null', 6900),
(36, 'La MaracuyÃ', 'ramal 1', 36, 1, 39, 0.97, 0.97, 'sin descripciµn', '1', 'null', 4462),
(37, 'El Guabo', 'ramal 1', 37, 1, 40, 1.15, 1.15, 'sin descripciµn', '1', 'null', 5290),
(38, 'La TÚa FelÃ', 'ramal 1', 38, 1, 41, 1.17, 1.17, 'sin descripciµn', '1', 'null', 5382),
(39, 'El Letrero', 'ramal 1', 39, 1, 42, 0.6, 0.6, 'sin descripciµn', '1', 'null', 2760),
(40, 'Las Vegas', 'ramal 1', 40, 1, 43, 1.27, 1.27, 'sin descripciµn', '1', 'null', 5842),
(41, 'Los PlÃtanos', 'ramal 1', 41, 1, 44, 0.94, 0.94, 'sin descripciµn', '1', 'null', 4324),
(42, 'Las Vegas', 'ramal 2', 1, 2, 43, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(43, 'El Milagro', 'ramal 2', 2, 2, 45, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(44, 'La 28', 'ramal 2', 3, 2, 46, 1.25, 1.25, 'sin descripciµn', '1', 'null', 5750),
(45, 'Parcela N¯ 25', 'ramal 2', 4, 2, 47, 2.04, 2.04, 'sin descripciµn', '1', 'null', 9384),
(46, 'La Chirimoya', 'ramal 2', 5, 2, 48, 1.24, 1.24, 'sin descripciµn', '1', 'null', 5704),
(47, 'El Limµn', 'ramal 2', 6, 2, 18, 1.95, 1.95, 'sin descripciµn', '1', 'null', 8970),
(48, 'El Molino', 'ramal 2', 7, 2, 49, 3.19, 3.19, 'sin descripciµn', '1', 'null', 14674),
(49, 'La Curva', 'ramal 2', 8, 2, 50, 0.93, 0.93, 'sin descripciµn', '1', 'null', 4278),
(50, 'El Tallo', 'ramal 2', 9, 2, 51, 0.95, 0.95, 'sin descripciµn', '1', 'null', 4370),
(51, 'El Huabo', 'ramal 2', 10, 2, 52, 1.05, 1.05, 'sin descripciµn', '1', 'null', 4830),
(52, 'La Hierba luisa', 'ramal 2', 11, 2, 53, 1.03, 1.03, 'sin descripciµn', '1', 'null', 4738),
(53, 'El Girasol', 'ramal 2', 12, 2, 54, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(54, 'El Pozo', 'ramal 2', 13, 2, 55, 0.98, 0.98, 'sin descripciµn', '1', 'null', 4508),
(55, 'Santa Maria', 'ramal 2', 14, 2, 56, 1.27, 1.27, 'sin descripciµn', '1', 'null', 5842),
(56, 'El Ventarrµn', 'ramal 2', 15, 2, 57, 0.91, 0.91, 'sin descripciµn', '1', 'null', 4186),
(57, 'La Guaba', 'ramal 2', 16, 2, 58, 4.84, 3, 'sin descripciµn', '1', 'null', 13800),
(58, 'La Perla ', 'ramal 2', 17, 2, 11, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(59, 'Jara', 'ramal 2', 18, 2, 59, 2.73, 2.5, 'sin descripciµn', '1', 'null', 11500),
(60, 'La Palta', 'ramal 2', 19, 2, 13, 2.82, 2.82, 'sin descripciµn', '1', 'null', 12972),
(61, 'El Tamarindo B', 'ramal 2', 20, 2, 60, 1.02, 1.02, 'sin descripciµn', '1', 'null', 4692),
(62, 'El Tamarindo A', 'ramal 2', 21, 2, 60, 0.9, 30, 'sin descripciµn', '1', 'null', 4140),
(63, 'El Algarrobo', 'ramal 2', 22, 2, 5, 1.23, 1.23, 'sin descripciµn', '1', 'null', 5658),
(64, 'El Mango', 'ramal 2', 23, 2, 61, 2.27, 2.27, 'sin descripciµn', '1', 'null', 10442),
(65, 'El Manantial', 'ramal 2', 24, 2, 62, 4.88, 4, 'sin descripciµn', '1', 'null', 18400),
(66, 'El Elefante', 'ramal 2', 25, 2, 29, 5.15, 5.15, 'sin descripciµn', '1', 'null', 23690),
(67, 'Los Mangos', 'ramal 2', 26, 2, 63, 2.06, 2.06, 'sin descripciµn', '1', 'null', 9476),
(68, 'El Algarrobo', 'ramal 2', 27, 2, 64, 3.06, 3.06, 'sin descripciµn', '1', 'null', 14076),
(69, 'El Girasol II', 'ramal 2', 28, 2, 54, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(70, 'La 16', 'ramal 2', 29, 2, 16, 5.07, 5.07, 'sin descripciµn', '1', 'null', 23322),
(71, 'La Ponderosa', 'ramal 2', 30, 2, 65, 1.08, 1.08, 'sin descripciµn', '1', 'null', 4968),
(72, 'Las Gaviotas', 'ramal 2', 31, 2, 27, 3.84, 1.5, 'sin descripciµn', '1', 'null', 6900),
(73, 'Las Tunas', 'ramal 2', 32, 2, 66, 1.6, 1.6, 'sin descripciµn', '1', 'null', 7360),
(74, 'Beal', 'ramal 2', 33, 2, 67, 8.2, 4, 'sin descripciµn', '1', 'null', 18400),
(75, 'El P\'itano', 'ramal 2', 34, 2, 68, 1.73, 1.73, 'sin descripciµn', '1', 'null', 7958),
(76, 'La Caþa', 'ramal 2', 35, 2, 69, 1.54, 1.54, 'sin descripciµn', '1', 'null', 7084),
(77, 'La Huaba', 'ramal 2', 36, 2, 70, 1.41, 1.41, 'sin descripciµn', '1', 'null', 6486),
(78, 'El Algarrobo', 'ramal 2', 37, 2, 71, 0.52, 0.52, 'sin descripciµn', '1', 'null', 2392),
(79, 'El Laurel', 'ramal 2', 38, 2, 72, 1.47, 1.47, 'sin descripciµn', '1', 'null', 6762),
(80, 'La Huayaba', 'ramal 2', 39, 2, 73, 1.5, 1.5, 'sin descripciµn', '1', 'null', 6900),
(81, 'El FrÕjol', 'ramal 2', 40, 2, 74, 1.68, 1.68, 'sin descripciµn', '1', 'null', 7728),
(82, 'La Taya', 'ramal 2', 41, 2, 75, 1.65, 1.65, 'sin descripciµn', '1', 'null', 7590),
(83, 'Jesºs', 'ramal 2', 42, 2, 76, 3.98, 3.98, 'sin descripciµn', '1', 'null', 18308),
(84, 'El Roclo', 'ramal 2', 43, 2, 77, 5, 3, 'sin descripciµn', '1', 'null', 13800),
(85, 'El Pacayal A', 'ramal 2', 44, 2, 78, 5.76, 3, 'sin descripciµn', '1', 'null', 13800),
(86, 'El Pacayal B', 'ramal 2', 45, 2, 78, 4.48, 3, 'sin descripciµn', '1', 'null', 13800),
(87, 'Lucero', 'ramal 2', 46, 2, 19, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(88, 'El Espino', 'ramal 2', 47, 2, 79, 4.98, 3, 'sin descripciµn', '1', 'null', 13800),
(89, 'la Granja', 'ramal 2', 48, 2, 80, 5.13, 5.13, 'sin descripciµn', '1', 'null', 23598),
(90, 'Los Rosales', 'ramal 2', 49, 2, 81, 4.94, 4.94, 'sin descripciµn', '1', 'null', 22724),
(91, 'Don Pedrito', 'ramal 2', 50, 2, 82, 1.96, 1.96, 'sin descripciµn', '1', 'null', 9016),
(92, 'El Mango', 'ramal 2', 51, 2, 2, 4.98, 3, 'sin descripciµn', '1', 'null', 13800),
(93, 'Los Girasoles', 'ramal 2', 52, 2, 83, 5.07, 3, 'sin descripciµn', '1', 'null', 13800),
(94, 'Pampa Hermosa', 'ramal 2', 53, 2, 84, 3.28, 3.28, 'sin descripciµn', '1', 'null', 15088),
(95, 'Parcela 125', 'ramal 2', 54, 2, 85, 1.53, 1.53, 'sin descripciµn', '1', 'null', 7038),
(96, 'El Algarrobo', 'ramal 2', 55, 2, 15, 4.87, 4.87, 'sin descripciµn', '1', 'null', 22402),
(97, 'La 30', 'ramal 2', 56, 2, 86, 4.98, 2, 'sin descripciµn', '1', 'null', 9200),
(98, 'La Granada', 'ramal 2', 57, 2, 87, 4.89, 4.89, 'sin descripciµn', '1', 'null', 22494),
(99, 'La Ciruela', 'ramal 2', 58, 2, 88, 5.03, 5.03, 'sin descripciµn', '1', 'null', 23138),
(100, 'El Algarrobo', 'ramal 2', 59, 2, 78, 5.42, 5.42, 'sin descripciµn', '1', 'null', 24932),
(101, 'El Triangulo', 'ramal 2', 60, 2, 89, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(102, 'El Rancho del TÚo Benny', 'ramal 2', 61, 2, 90, 5.02, 5.02, 'sin descripciµn', '1', 'null', 23092),
(103, 'La TÚa FelÃ 2', 'ramal 2', 62, 2, 41, 3.87, 3.87, 'sin descripciµn', '1', 'null', 17802),
(104, 'Los Cocos', 'ramal 2', 63, 2, 91, 5.1, 5.1, 'sin descripciµn', '1', 'null', 23460),
(105, 'La Cana', 'ramal 2', 64, 2, 92, 2.01, 2.01, 'sin descripciµn', '1', 'null', 9246),
(106, 'El ParaÚso', 'ramal 2', 65, 2, 27, 1.94, 1.94, 'sin descripciµn', '1', 'null', 8924),
(107, 'Bella Vista', 'ramal 2', 66, 2, 45, 4.05, 4.05, 'sin descripciµn', '1', 'null', 18630),
(108, 'Allana', 'ramal 2', 67, 2, 31, 3.89, 3, 'sin descripciµn', '1', 'null', 13800),
(109, 'Los Guabos', 'ramal 2', 68, 2, 93, 2.84, 2.84, 'sin descripciµn', '1', 'null', 13064),
(110, 'Franco', 'ramal 2', 69, 2, 94, 4.37, 4.37, 'sin descripciµn', '1', 'null', 20102),
(111, 'El Mirador', 'ramal 2', 70, 2, 95, 5.03, 5.03, 'sin descripciµn', '1', 'null', 23138),
(112, 'El Mirador', 'ramal 2', 71, 2, 96, 5.61, 5.61, 'sin descripciµn', '1', 'null', 25806),
(113, 'El Mirador', 'ramal 2', 72, 2, 97, 1.8, 1.8, 'sin descripciµn', '1', 'null', 8280),
(114, 'El Porvenir', 'ramal 2', 73, 2, 98, 2.32, 2.32, 'sin descripciµn', '1', 'null', 10672),
(115, 'El Mirador', 'ramal 2', 74, 2, 99, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(116, 'Palmera I', 'ramal 2', 75, 2, 37, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(117, 'Las Palmeras II', 'ramal 2', 76, 2, 100, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(118, 'La Huaba', 'ramal 2', 77, 2, 101, 1.92, 1.92, 'sin descripciµn', '1', 'null', 8832),
(119, 'la Palta', 'ramal 2', 78, 2, 13, 2.06, 2.06, 'sin descripciµn', '1', 'null', 9476),
(120, 'El Mamey', 'ramal 2', 79, 2, 102, 3.89, 3.89, 'sin descripciµn', '1', 'null', 17894),
(121, 'Perla Verde', 'ramal 2', 80, 2, 52, 4.09, 4.09, 'sin descripciµn', '1', 'null', 18814),
(122, 'la Naranja', 'ramal 2', 81, 2, 103, 4.01, 4.01, 'sin descripciµn', '1', 'null', 18446),
(123, 'El Algarrobo', 'ramal 2', 82, 2, 104, 8.36, 5, 'sin descripciµn', '1', 'null', 23000),
(124, 'La Libertad', 'ramal 2', 83, 2, 105, 22, 22, 'sin descripciµn', '1', 'null', 98200),
(125, 'Las Gemelas', 'ramal 2', 84, 2, 106, 4.04, 4, 'sin descripciµn', '1', 'null', 18400),
(126, 'El Naranjal', 'ramal 2', 85, 2, 28, 3.95, 3.95, 'sin descripciµn', '1', 'null', 18170),
(127, 'El Cerro', 'ramal 2', 86, 2, 48, 4.74, 4.74, 'sin descripciµn', '1', 'null', 21804),
(128, 'Las Brisas', 'ramal 2', 87, 2, 107, 4.3, 4.9, 'sin descripciµn', '1', 'null', 18400),
(129, 'La Piscina', 'ramal 2', 88, 2, 108, 3.57, 3, 'sin descripciµn', '1', 'null', 13800),
(130, 'San Javier', 'ramal 3', 1, 3, 109, 5.01, 5.01, 'sin descripciµn', '1', 'null', 23046),
(131, 'La Guaba', 'ramal 3', 2, 3, 110, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(132, 'Parcela N\' 58 A', 'ramal 3', 3, 3, 111, 0.8, 0.8, 'sin descripciµn', '1', 'null', 3680),
(133, 'Parcela N* 58 B', 'ramal 3', 4, 3, 111, 4.2, 4.2, 'sin descripciµn', '1', 'null', 19320),
(134, 'Parcela N* 59 A', 'ramal 3', 5, 3, 113, 1.98, 1.98, 'sin descripciµn', '1', 'null', 9108),
(135, 'Parcela N* 59 B', 'ramal 3', 6, 3, 113, 3.02, 3.02, 'sin descripciµn', '1', 'null', 13892),
(136, 'Parcela N* 60 A', 'ramal 3', 7, 3, 112, 2.47, 2.47, 'sin descripciµn', '1', 'null', 11362),
(137, 'Parcela N* 60 B', 'ramal 3', 8, 3, 112, 2.58, 2.58, 'sin descripciµn', '1', 'null', 11868),
(138, 'Parcela N* 80', 'ramal 3', 9, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(139, 'Parcela N* 79', 'ramal 3', 10, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(140, 'Parcela N* 78', 'ramal 3', 11, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(141, 'Parcela N* 77', 'ramal 3', 12, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(142, '\"Parcela N\"\" 74\"', 'ramal 3', 13, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(143, 'Parcela N* 73', 'ramal 3', 14, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(144, 'Parcela N\' 71', 'ramal 3', 15, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(145, 'Parcela N* 33', 'ramal 3', 16, 3, 113, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(146, 'Parcela N* 34', 'ramal 3', 17, 3, 113, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(147, 'Claudia', 'ramal 3', 18, 3, 114, 2.86, 2.86, 'sin descripciµn', '1', 'null', 13156),
(148, 'La 72', 'ramal 3', 19, 3, 115, 2.27, 2.27, 'sin descripciµn', '1', 'null', 10442),
(149, 'Ana Myle', 'ramal 3', 20, 3, 35, 10.02, 10.02, 'sin descripciµn', '1', 'null', 46092),
(150, 'Los Platanales B', 'ramal 3', 21, 3, 57, 0.96, 0.96, 'sin descripciµn', '1', 'null', 4416),
(151, 'Los Platanales A', 'ramal 3', 22, 3, 57, 0.72, 0.72, 'sin descripciµn', '1', 'null', 3312),
(152, 'El Platanal A', 'ramal 3', 23, 3, 116, 1.93, 1.93, 'sin descripciµn', '1', 'null', 8878),
(153, 'El Platanal B', 'ramal 3', 24, 3, 116, 0.76, 0.76, 'sin descripciµn', '1', 'null', 3496),
(154, 'Santa Rosa', 'ramal 3', 25, 3, 117, 0.73, 0.73, 'sin descripciµn', '1', 'null', 3358),
(155, 'La Taya', 'ramal 3', 26, 3, 108, 1.9, 1.9, 'sin descripciµn', '1', 'null', 8740),
(156, 'El Manantial B', 'ramal 3', 27, 3, 118, 0.43, 0.43, 'sin descripciµn', '1', 'null', 1978),
(157, 'El Manantial A', 'ramal 3', 28, 3, 118, 4.62, 4.62, 'sin descripciµn', '1', 'null', 21252),
(158, 'La Taya 2', 'ramal 3', 29, 3, 108, 2.99, 2.99, 'sin descripciµn', '1', 'null', 13754),
(159, 'La Esperanza', 'ramal 3', 30, 3, 119, 3.14, 3.14, 'sin descripciµn', '1', 'null', 14444),
(160, 'Las Moringas', 'ramal 3', 31, 3, 120, 5.05, 5.05, 'sin descripciµn', '1', 'null', 23230),
(161, 'El Laurel', 'ramal 3', 32, 3, 121, 1.04, 1.04, 'sin descripciµn', '1', 'null', 4784),
(162, 'El Laurel', 'ramal 3', 33, 3, 122, 1.2, 1.2, 'sin descripciµn', '1', 'null', 5520),
(163, 'La Esperanza', 'ramal 3', 34, 3, 123, 4.68, 4.68, 'sin descripciµn', '1', 'null', 21528),
(164, 'Manolo', 'ramal 3', 35, 3, 124, 4.27, 4.27, 'sin descripciµn', '1', 'null', 19642),
(165, 'Las Brisas', 'ramal 3', 36, 3, 125, 5.11, 5, 'sin descripciµn', '1', 'null', 23000),
(166, 'Las Casuarinas', 'ramal 3', 37, 3, 126, 4.44, 4.44, 'sin descripciµn', '1', 'null', 20424),
(167, 'Las Casuarinas', 'ramal 3', 38, 3, 127, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(168, 'El Pino', 'ramal 3', 39, 3, 128, 2.37, 2.37, 'sin descripciµn', '1', 'null', 10902),
(169, 'El Algarrobo', 'ramal 3', 40, 3, 129, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(170, 'El Alfalfar', 'ramal 3', 41, 3, 130, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(171, 'Campo Verde', 'ramal 3', 42, 3, 131, 4.88, 4.88, 'sin descripciµn', '1', 'null', 22448),
(172, 'Don Juan', 'ramal 3', 43, 3, 132, 1.12, 1.12, 'sin descripciµn', '1', 'null', 5152),
(173, 'la Hierba Santa', 'ramal 3', 44, 3, 133, 4.7, 4, 'sin descripciµn', '1', 'null', 18400),
(174, 'El Sauce', 'ramal 3', 45, 3, 134, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(175, 'Fundo Greda', 'ramal 3', 46, 3, 135, 3.8, 3, 'sin descripciµn', '1', 'null', 13800),
(176, 'La Fortuna', 'ramal 3', 47, 3, 136, 3.44, 3.44, 'sin descripciµn', '1', 'null', 15824),
(177, 'El Pacay', 'ramal 3', 48, 3, 137, 2.61, 2.61, 'sin descripciµn', '1', 'null', 12006),
(178, 'La Guaripera', 'ramal 3', 49, 3, 138, 4.92, 4.92, 'sin descripciµn', '1', 'null', 22632),
(179, 'Las Tayas', 'ramal 3', 50, 3, 139, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(180, 'Los Cocos', 'ramal 3', 51, 3, 91, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(181, 'La Palta', 'ramal 3', 52, 3, 140, 1.55, 1.55, 'sin descripciµn', '1', 'null', 7130),
(182, 'Pajarobobo', 'ramal 3', 53, 3, 141, 1.14, 1.14, 'sin descripciµn', '1', 'null', 5244),
(183, 'Ariana', 'ramal 3', 54, 3, 142, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(184, 'Hualgayoc', 'ramal 3', 55, 3, 143, 15, 15, 'sin descripciµn', '1', 'null', 69000),
(185, 'El Rejo', 'ramal 3', 56, 3, 144, 2.55, 2.55, 'sin descripciµn', '1', 'null', 11730),
(186, 'Los PÚa taþos', 'ramal 3', 57, 3, 145, 1.83, 1.83, 'sin descripciµn', '1', 'null', 8418),
(187, 'El Algarrobo', 'ramal 3', 58, 3, 146, 2.96, 2.96, 'sin descripciµn', '1', 'null', 13616),
(188, 'La Almendra', 'ramal 3', 59, 3, 147, 2.05, 2, 'sin descripciµn', '1', 'null', 9200),
(189, 'La Parcela 62', 'ramal 3', 60, 3, 148, 3.95, 3.95, 'sin descripciµn', '1', 'null', 18170),
(190, 'El Algarrobo', 'ramal 3', 61, 3, 149, 1.94, 1.94, 'sin descripciµn', '1', 'null', 8924),
(191, 'Aldemar', 'ramal 3', 62, 3, 46, 4.11, 4.11, 'sin descripciµn', '1', 'null', 18906),
(192, 'Lla 69', 'ramal 3', 63, 3, 150, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(193, 'La 38', 'ramal 3', 64, 3, 151, 1.62, 1.62, 'sin descripciµn', '1', 'null', 7452),
(194, 'La 63 A', 'ramal 3', 65, 3, 149, 3.79, 3.79, 'sin descripciµn', '1', 'null', 17434),
(195, 'La 63 8', 'ramal 3', 66, 3, 149, 1.15, 1.15, 'sin descripciµn', '1', 'null', 5290),
(196, 'Los Pozos', 'ramal 3', 67, 3, 152, 2.83, 2.5, 'sin descripciµn', '1', 'null', 11500),
(197, 'Santana', 'ramal 3', 68, 3, 105, 10, 10, 'sin descripciµn', '1', 'null', 46000),
(198, 'La 44', 'ramal 3', 69, 3, 146, 3.78, 3.78, 'sin descripciµn', '1', 'null', 17388),
(199, 'Las Compuertas', 'ramal 3', 70, 3, 148, 3.95, 3.95, 'sin descripciµn', '1', 'null', 18170),
(200, 'El Algarrobo I', 'ramal 3', 71, 3, 153, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(201, 'El Desaguadero', 'ramal 3', 72, 3, 148, 3.07, 3.07, 'sin descripciµn', '1', 'null', 14122),
(202, 'Los Espinos', 'ramal 3', 73, 3, 154, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(203, 'El Algarrobo II', 'ramal 3', 74, 3, 155, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(204, 'La Casita de Ladrino', 'ramal 3', 75, 3, 156, 4.62, 4.62, 'sin descripciµn', '1', 'null', 21252),
(205, 'La Costa Verde', 'ramal 3', 76, 3, 157, 3.2, 3.2, 'sin descripciµn', '1', 'null', 14720),
(206, 'Las Tres Guabas', 'ramal 4', 1, 4, 158, 2.6, 2.6, 'sin descripciµn', '1', 'null', 11960),
(207, 'El Sendero', 'ramal 4', 2, 4, 125, 0.92, 0.92, 'sin descripciµn', '1', 'null', 4232),
(208, 'El Tamarindo', 'ramal 4', 3, 4, 108, 3.74, 3, 'sin descripciµn', '1', 'null', 13800),
(209, 'Carmelita', 'ramal 4', 4, 4, 159, 4.96, 3, 'sin descripciµn', '1', 'null', 13800),
(210, 'El Eucalipto', 'ramal 4', 5, 4, 160, 3.94, 3.94, 'sin descripciµn', '1', 'null', 18124),
(211, 'El Eucalipto', 'ramal 4', 6, 4, 148, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(212, 'Los Huabos', 'ramal 4', 7, 4, 148, 4.18, 4.18, 'sin descripciµn', '1', 'null', 19228),
(213, 'Ariana', 'ramal 4', 8, 4, 142, 3, 3, 'sin descripciµn', '1', 'null', 13800),
(214, 'El Algarrobo', 'ramal 4', 9, 4, 149, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(215, 'La Granada', 'ramal 4', 10, 4, 32, 2.03, 2.03, 'sin descripciµn', '1', 'null', 9338),
(216, 'Campo Mar', 'ramal 4', 11, 4, 161, 3.91, 3.91, 'sin descripciµn', '1', 'null', 17986),
(217, 'La 61', 'ramal 4', 12, 4, 162, 3.95, 3.95, 'sin descripciµn', '1', 'null', 18170),
(218, 'La Guaba', 'ramal 4', 13, 4, 155, 1.19, 1.19, 'sin descripciµn', '1', 'null', 5474),
(219, 'La Hacienda SÃnchez', 'ramal 4', 14, 4, 153, 2.44, 2.44, 'sin descripciµn', '1', 'null', 11224),
(220, 'La Papaya', 'ramal 5', 1, 5, 165, 4.63, 4, 'sin descripciµn', '1', 'null', 18400),
(221, 'La Paltµ', 'ramal 5', 2, 5, 166, 1.83, 1.83, 'sin descripciµn', '2', 'null', 8418),
(222, 'El Milagro', 'ramal 5', 3, 5, 167, 3.75, 3, 'sin descripciµn', '3', 'null', 13800),
(223, 'Las Delicias', 'ramal 5', 4, 5, 168, 4, 2, 'sin descripciµn', '4', 'null', 9200),
(224, 'El Pino', 'ramal 5', 5, 5, 165, 3.94, 3.94, 'sin descripciµn', '5', 'null', 18124),
(225, 'La MaracuyÃ', 'ramal 5', 6, 5, 20, 4.01, 4, 'sin descripciµn', '6', 'null', 18400),
(226, 'La Guayaba', 'ramal 5', 7, 5, 20, 3.83, 3.83, 'sin descripciµn', '7', 'null', 17618),
(227, 'Nºmero 42', 'ramal 5', 8, 5, 169, 4.43, 4.43, 'sin descripciµn', '8', 'null', 20378),
(228, 'El EdÕn', 'ramal 5', 9, 5, 170, 4.55, 4.55, 'sin descripciµn', '9', 'null', 20930),
(229, 'La Pampa', 'ramal 5', 10, 5, 171, 3.9, 3.9, 'sin descripciµn', '10', 'null', 17940),
(230, 'Las Flores', 'ramal 5', 11, 5, 172, 3.97, 3.97, 'sin descripciµn', '11', 'null', 18262),
(231, 'El Manuel', 'ramal 5', 12, 5, 173, 5.51, 5.51, 'sin descripciµn', '12', 'null', 25346),
(232, 'Los Algarrobos', 'ramal 5', 13, 5, 174, 3.77, 3.77, 'sin descripciµn', '13', 'null', 17342),
(233, 'Platanal', 'ramal 5', 14, 5, 175, 0.84, 0.84, 'sin descripciµn', '14', 'null', 3864),
(234, 'La Granada', 'ramal 5', 15, 5, 176, 0.97, 0.97, 'sin descripciµn', '15', 'null', 4462),
(235, 'El Espino', 'ramal 5', 16, 5, 177, 1, 1, 'sin descripciµn', '16', 'null', 4462),
(236, 'El Zapotal', 'ramal 5', 17, 5, 178, 5, 5, 'sin descripciµn', '17', 'null', 23000),
(237, 'LosJasmines', 'ramal 5', 18, 5, 179, 1.03, 1.03, 'sin descripciµn', '18', 'null', 4738),
(238, 'El Guabo A', 'ramal 5', 19, 5, 180, 1.24, 1.24, 'sin descripciµn', '19', 'null', 5704),
(239, 'El Guabo B', 'ramal 5', 20, 5, 180, 0.33, 0.33, 'sin descripciµn', '20', 'null', 1518),
(240, 'La Bocana', 'ramal 5', 21, 5, 181, 3.5, 3.5, 'sin descripciµn', '21', 'null', 16100),
(241, 'Maquiabelo', 'ramal 5', 22, 5, 182, 6.02, 6.02, 'sin descripciµn', '22', 'null', 27692),
(242, 'Parcela 84', 'ramal 5', 23, 5, 183, 4.8, 4.8, 'sin descripciµn', '23', 'null', 22080),
(243, 'El Triunfo A', 'ramal 5', 24, 5, 123, 2.75, 2.75, 'sin descripciµn', '24', 'null', 12650),
(244, 'El Triunfo B', 'ramal 5', 25, 5, 123, 5.08, 5.08, 'sin descripciµn', '25', 'null', 23368),
(245, 'El Chilo', 'ramal 5', 26, 5, 17, 5, 5, 'sin descripciµn', '26', 'null', 23000),
(246, 'Las Moradas', 'ramal 5', 27, 5, 184, 3.02, 3.02, 'sin descripciµn', '27', 'null', 13892),
(247, 'El Eucalipto', 'ramal 5', 28, 5, 185, 1.84, 1.84, 'sin descripciµn', '28', 'null', 8464),
(248, 'El Alfalfar', 'ramal 5', 29, 5, 186, 4, 4, 'sin descripciµn', '29', 'null', 18400),
(249, 'La Merced', 'ramal 5', 30, 5, 187, 4, 1, 'sin descripciµn', '30', 'null', 4600),
(250, 'La Pradera', 'ramal 5', 31, 5, 188, 5.06, 5.06, 'sin descripciµn', '31', 'null', 23276),
(251, 'Los Eucaliptos', 'ramal 5', 32, 5, 189, 1.01, 1.01, 'sin descripciµn', '32', 'null', 4646),
(252, 'Jennery Jesibell', 'ramal 5', 33, 5, 190, 1.87, 1.87, 'sin descripciµn', '33', 'null', 8602),
(253, 'Dos Hermanos', 'ramal 5', 34, 5, 191, 1, 1, 'sin descripciµn', '34', 'null', 4600),
(254, 'Los Guabos ', 'ramal 5', 35, 5, 192, 1, 1, 'sin descripciµn', '35', 'null', 0),
(255, 'La Curva', 'ramal 5', 36, 5, 128, 1.79, 1.79, 'sin descripciµn', '36', 'null', 8234),
(256, 'La Caþa', 'ramal 5', 37, 5, 193, 2.27, 2.27, 'sin descripciµn', '37', 'null', 10442),
(257, 'Parcela 56', 'ramal 5', 38, 5, 18, 3.78, 3.78, 'sin descripciµn', '38', 'null', 17388),
(258, 'El Refugio 87', 'ramal 5', 39, 5, 194, 5, 5, 'sin descripciµn', '39', 'null', 23000),
(259, 'El Salvador', 'ramal 5', 40, 5, 152, 1.84, 1.84, 'sin descripciµn', '40', 'null', 8464),
(260, 'Los Pozos', 'ramal 5', 41, 5, 152, 2.83, 2.83, 'sin descripciµn', '41', 'null', 13018);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reparto`
--

CREATE TABLE `reparto` (
  `id_reparto` int(11) NOT NULL,
  `descripcion` varchar(500) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `fecha_reparto` date DEFAULT NULL,
  `hora_reparto` time DEFAULT NULL,
  `estado` varchar(1) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `reparto`
--

INSERT INTO `reparto` (`id_reparto`, `descripcion`, `tipo`, `fecha_registro`, `fecha_reparto`, `hora_reparto`, `estado`) VALUES
(4, 'Esta se guardará', 'General', '2018-11-09', '2019-08-02', '16:30:00', '3'),
(7, 'dsaDS', 'Para Chayas', '2018-11-07', '2019-08-05', '12:12:00', '3'),
(8, 'Uno más.', 'Para Chayas', '2018-11-10', '2019-08-10', '12:30:00', '3'),
(9, 'Lo cerramos.', 'General', '2018-11-22', '2019-08-02', '12:30:00', '3'),
(10, 'Lo cerramos.', 'General', '2018-11-26', '2019-08-07', '16:40:00', '2'),
(11, 'bbb', 'Especial', '2018-11-26', '2019-08-08', '12:30:00', '1'),
(12, 'w', 'Para Chayas', NULL, '2019-08-06', '12:12:00', '2'),
(13, 'cdasvdssavfssa', 'Para Chayas', NULL, '2019-08-05', '16:30:00', '3'),
(14, 'REALIZADO PARA PRUEBAS DE ESTADO.', 'Para Chayas', NULL, '2019-08-09', '12:30:00', '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `talonario`
--

CREATE TABLE `talonario` (
  `id_talonario` int(11) NOT NULL,
  `codigo` int(11) DEFAULT NULL,
  `descripcion` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `primer_ticket` int(11) DEFAULT NULL,
  `cantidad_tickets` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_futbolistas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_futbolistas` (
`id_parcela` int(11)
,`nombre` varchar(60)
,`ubicacion` varchar(150)
,`num_toma` int(11)
,`id_canal` int(11)
,`id_auth_user` int(11)
,`total_has` double
,`has_sembradas` double
,`descripcion` varchar(100)
,`estado` varchar(15)
,`codigo_predio` varchar(25)
,`volumen_agua` float
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_parcelas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_parcelas` (
`id_parcela` int(11)
,`nombre` varchar(60)
,`ubicacion` varchar(150)
,`num_toma` int(11)
,`id_canal` int(11)
,`id_auth_user` int(11)
,`total_has` double
,`has_sembradas` double
,`descripcion` varchar(100)
,`estado` varchar(15)
,`codigo_predio` varchar(25)
,`volumen_agua` float
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_futbolistas`
--
DROP TABLE IF EXISTS `vista_futbolistas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_futbolistas`  AS  (select `p`.`id_parcela` AS `id_parcela`,`p`.`nombre` AS `nombre`,`p`.`ubicacion` AS `ubicacion`,`p`.`num_toma` AS `num_toma`,`p`.`id_canal` AS `id_canal`,`p`.`id_auth_user` AS `id_auth_user`,`p`.`total_has` AS `total_has`,`p`.`has_sembradas` AS `has_sembradas`,`p`.`descripcion` AS `descripcion`,`p`.`estado` AS `estado`,`p`.`codigo_predio` AS `codigo_predio`,`p`.`volumen_agua` AS `volumen_agua` from (`parcela` `p` join `canal` `c` on((`p`.`id_canal` = `c`.`id_canal`))) where (`c`.`id_canal` = 3)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_parcelas`
--
DROP TABLE IF EXISTS `v_parcelas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_parcelas`  AS  select `p`.`id_parcela` AS `id_parcela`,`p`.`nombre` AS `nombre`,`p`.`ubicacion` AS `ubicacion`,`p`.`num_toma` AS `num_toma`,`p`.`id_canal` AS `id_canal`,`p`.`id_auth_user` AS `id_auth_user`,`p`.`total_has` AS `total_has`,`p`.`has_sembradas` AS `has_sembradas`,`p`.`descripcion` AS `descripcion`,`p`.`estado` AS `estado`,`p`.`codigo_predio` AS `codigo_predio`,`p`.`volumen_agua` AS `volumen_agua` from (`parcela` `p` join `canal` `c` on((`p`.`id_canal` = `c`.`id_canal`))) where (`c`.`id_canal` = 3) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `agenda_asamblea`
--
ALTER TABLE `agenda_asamblea`
  ADD PRIMARY KEY (`id_agenda`),
  ADD KEY `fk_asa_age_idx` (`id_asamblea`);

--
-- Indices de la tabla `archivos_parcela`
--
ALTER TABLE `archivos_parcela`
  ADD PRIMARY KEY (`id_archivos_parcela`),
  ADD KEY `fk_par_arc_idx` (`id_parcela`);

--
-- Indices de la tabla `asamblea`
--
ALTER TABLE `asamblea`
  ADD PRIMARY KEY (`id_asamblea`);

--
-- Indices de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indices de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indices de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indices de la tabla `auth_user`
--
ALTER TABLE `auth_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indices de la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  ADD KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`);

--
-- Indices de la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  ADD KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`);

--
-- Indices de la tabla `canal`
--
ALTER TABLE `canal`
  ADD PRIMARY KEY (`id_canal`);

--
-- Indices de la tabla `caudal`
--
ALTER TABLE `caudal`
  ADD PRIMARY KEY (`id_caudal`),
  ADD KEY `fk_can_cau_idx` (`id_canal`);

--
-- Indices de la tabla `comite`
--
ALTER TABLE `comite`
  ADD PRIMARY KEY (`id_comite`);

--
-- Indices de la tabla `comprobante`
--
ALTER TABLE `comprobante`
  ADD PRIMARY KEY (`id_comprobante`),
  ADD KEY `fk_tal_comp_idx` (`id_talonario`);

--
-- Indices de la tabla `comp_multa`
--
ALTER TABLE `comp_multa`
  ADD PRIMARY KEY (`id_comp_multa`),
  ADD KEY `fk_mul_comp_mul_idx` (`id_multa`),
  ADD KEY `fk_comp_comp_mul_idx` (`id_comprobante`);

--
-- Indices de la tabla `comp_orden`
--
ALTER TABLE `comp_orden`
  ADD PRIMARY KEY (`id_comp_orden`),
  ADD KEY `fk_comp_comp_ord_idx` (`id_comprobante`),
  ADD KEY `fk_ord_comp_ord_idx` (`id_orden`);

--
-- Indices de la tabla `datos_personales`
--
ALTER TABLE `datos_personales`
  ADD PRIMARY KEY (`id_datos_personales`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `destajo`
--
ALTER TABLE `destajo`
  ADD PRIMARY KEY (`id_destajo`),
  ADD KEY `fk_can_des_idx` (`id_canal`),
  ADD KEY `fk_par_des_idx` (`id_parcela`);

--
-- Indices de la tabla `det_asamb_canal`
--
ALTER TABLE `det_asamb_canal`
  ADD PRIMARY KEY (`id_dt_asmb_canal`),
  ADD KEY `id_dt_asmb_canal` (`id_dt_asmb_canal`),
  ADD KEY `id_canal` (`id_canal`),
  ADD KEY `id_asamblea` (`id_asamblea`);

--
-- Indices de la tabla `det_limpieza`
--
ALTER TABLE `det_limpieza`
  ADD PRIMARY KEY (`id_det_limpieza`),
  ADD KEY `fk_des_det_idx` (`id_destajo`),
  ADD KEY `fk_lim_det_idx` (`id_limpieza`);

--
-- Indices de la tabla `det_lista`
--
ALTER TABLE `det_lista`
  ADD PRIMARY KEY (`id_det_lista`),
  ADD KEY `fk_lis_det_lis_idx` (`id_lista`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `direccion`
--
ALTER TABLE `direccion`
  ADD PRIMARY KEY (`id_direccion`),
  ADD KEY `fk_per_dir_idx` (`id_datos_personales`);

--
-- Indices de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`);

--
-- Indices de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indices de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- Indices de la tabla `hoja_asistencia`
--
ALTER TABLE `hoja_asistencia`
  ADD PRIMARY KEY (`id_hoja_asistencia`),
  ADD KEY `fk_asam_asis_idx` (`id_asamblea`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `limpieza`
--
ALTER TABLE `limpieza`
  ADD PRIMARY KEY (`id_limpieza`);

--
-- Indices de la tabla `lista`
--
ALTER TABLE `lista`
  ADD PRIMARY KEY (`id_lista`),
  ADD KEY `fk_com_lis_idx` (`id_comite`);

--
-- Indices de la tabla `multa`
--
ALTER TABLE `multa`
  ADD PRIMARY KEY (`id_multa`);

--
-- Indices de la tabla `multa_asistencia`
--
ALTER TABLE `multa_asistencia`
  ADD PRIMARY KEY (`id_multa_asistencia`),
  ADD KEY `fk_mul_asis_idx` (`id_multa`),
  ADD KEY `fk_asi_mul_asi_idx` (`id_hoja_asistencia`);

--
-- Indices de la tabla `multa_limpia`
--
ALTER TABLE `multa_limpia`
  ADD PRIMARY KEY (`id_multa_limpia`),
  ADD KEY `fk_mul_mul_lim_idx` (`id_multa`),
  ADD KEY `fk_det_lim_mul_lim_idx` (`id_det_limpia`);

--
-- Indices de la tabla `multa_orden`
--
ALTER TABLE `multa_orden`
  ADD PRIMARY KEY (`id_multa_orden`),
  ADD KEY `fk_mul_ord_idx` (`id_orden`),
  ADD KEY `fk_mul_mul_ord_idx` (`id_multa`);

--
-- Indices de la tabla `noticia`
--
ALTER TABLE `noticia`
  ADD PRIMARY KEY (`id_noticia`);

--
-- Indices de la tabla `obra`
--
ALTER TABLE `obra`
  ADD PRIMARY KEY (`id_obra`),
  ADD KEY `fk_can_obr_idx` (`id_canal`);

--
-- Indices de la tabla `orden_riego`
--
ALTER TABLE `orden_riego`
  ADD PRIMARY KEY (`id_orden_riego`),
  ADD KEY `fk_rep_ord_idx` (`id_reparto`),
  ADD KEY `fk_par_ord_idx` (`id_parcela`);

--
-- Indices de la tabla `parcela`
--
ALTER TABLE `parcela`
  ADD PRIMARY KEY (`id_parcela`),
  ADD KEY `fk_can_par_idx` (`id_canal`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `reparto`
--
ALTER TABLE `reparto`
  ADD PRIMARY KEY (`id_reparto`);

--
-- Indices de la tabla `talonario`
--
ALTER TABLE `talonario`
  ADD PRIMARY KEY (`id_talonario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `agenda_asamblea`
--
ALTER TABLE `agenda_asamblea`
  MODIFY `id_agenda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT de la tabla `archivos_parcela`
--
ALTER TABLE `archivos_parcela`
  MODIFY `id_archivos_parcela` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `asamblea`
--
ALTER TABLE `asamblea`
  MODIFY `id_asamblea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=198;

--
-- AUTO_INCREMENT de la tabla `auth_user`
--
ALTER TABLE `auth_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=195;

--
-- AUTO_INCREMENT de la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `canal`
--
ALTER TABLE `canal`
  MODIFY `id_canal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `caudal`
--
ALTER TABLE `caudal`
  MODIFY `id_caudal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `comite`
--
ALTER TABLE `comite`
  MODIFY `id_comite` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comprobante`
--
ALTER TABLE `comprobante`
  MODIFY `id_comprobante` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comp_multa`
--
ALTER TABLE `comp_multa`
  MODIFY `id_comp_multa` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comp_orden`
--
ALTER TABLE `comp_orden`
  MODIFY `id_comp_orden` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `datos_personales`
--
ALTER TABLE `datos_personales`
  MODIFY `id_datos_personales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `destajo`
--
ALTER TABLE `destajo`
  MODIFY `id_destajo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=480;

--
-- AUTO_INCREMENT de la tabla `det_asamb_canal`
--
ALTER TABLE `det_asamb_canal`
  MODIFY `id_dt_asmb_canal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `det_limpieza`
--
ALTER TABLE `det_limpieza`
  MODIFY `id_det_limpieza` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `det_lista`
--
ALTER TABLE `det_lista`
  MODIFY `id_det_lista` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `direccion`
--
ALTER TABLE `direccion`
  MODIFY `id_direccion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `hoja_asistencia`
--
ALTER TABLE `hoja_asistencia`
  MODIFY `id_hoja_asistencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5693;

--
-- AUTO_INCREMENT de la tabla `limpieza`
--
ALTER TABLE `limpieza`
  MODIFY `id_limpieza` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `lista`
--
ALTER TABLE `lista`
  MODIFY `id_lista` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa`
--
ALTER TABLE `multa`
  MODIFY `id_multa` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa_asistencia`
--
ALTER TABLE `multa_asistencia`
  MODIFY `id_multa_asistencia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa_limpia`
--
ALTER TABLE `multa_limpia`
  MODIFY `id_multa_limpia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa_orden`
--
ALTER TABLE `multa_orden`
  MODIFY `id_multa_orden` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `noticia`
--
ALTER TABLE `noticia`
  MODIFY `id_noticia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `obra`
--
ALTER TABLE `obra`
  MODIFY `id_obra` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `orden_riego`
--
ALTER TABLE `orden_riego`
  MODIFY `id_orden_riego` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `parcela`
--
ALTER TABLE `parcela`
  MODIFY `id_parcela` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=261;

--
-- AUTO_INCREMENT de la tabla `reparto`
--
ALTER TABLE `reparto`
  MODIFY `id_reparto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `talonario`
--
ALTER TABLE `talonario`
  MODIFY `id_talonario` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `agenda_asamblea`
--
ALTER TABLE `agenda_asamblea`
  ADD CONSTRAINT `fk_asa_age` FOREIGN KEY (`id_asamblea`) REFERENCES `asamblea` (`id_asamblea`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `archivos_parcela`
--
ALTER TABLE `archivos_parcela`
  ADD CONSTRAINT `fk_par_arc` FOREIGN KEY (`id_parcela`) REFERENCES `parcela` (`id_parcela`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Filtros para la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Filtros para la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  ADD CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  ADD CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  ADD CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `caudal`
--
ALTER TABLE `caudal`
  ADD CONSTRAINT `fk_can_cau` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comprobante`
--
ALTER TABLE `comprobante`
  ADD CONSTRAINT `fk_tal_comp` FOREIGN KEY (`id_talonario`) REFERENCES `talonario` (`id_talonario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comp_multa`
--
ALTER TABLE `comp_multa`
  ADD CONSTRAINT `fk_comp_comp_mul` FOREIGN KEY (`id_comprobante`) REFERENCES `comprobante` (`id_comprobante`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_comp_mul` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comp_orden`
--
ALTER TABLE `comp_orden`
  ADD CONSTRAINT `fk_comp_comp_ord` FOREIGN KEY (`id_comprobante`) REFERENCES `comprobante` (`id_comprobante`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_ord_comp_ord` FOREIGN KEY (`id_orden`) REFERENCES `orden_riego` (`id_orden_riego`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `datos_personales`
--
ALTER TABLE `datos_personales`
  ADD CONSTRAINT `datos_personales_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `destajo`
--
ALTER TABLE `destajo`
  ADD CONSTRAINT `fk_can_des` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_par_des` FOREIGN KEY (`id_parcela`) REFERENCES `parcela` (`id_parcela`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `det_asamb_canal`
--
ALTER TABLE `det_asamb_canal`
  ADD CONSTRAINT `det_asamb_canal_ibfk_1` FOREIGN KEY (`id_asamblea`) REFERENCES `asamblea` (`id_asamblea`),
  ADD CONSTRAINT `det_asamb_canal_ibfk_2` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`);

--
-- Filtros para la tabla `det_limpieza`
--
ALTER TABLE `det_limpieza`
  ADD CONSTRAINT `fk_des_det` FOREIGN KEY (`id_destajo`) REFERENCES `destajo` (`id_destajo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_lim_det` FOREIGN KEY (`id_limpieza`) REFERENCES `limpieza` (`id_limpieza`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `det_lista`
--
ALTER TABLE `det_lista`
  ADD CONSTRAINT `det_lista_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`),
  ADD CONSTRAINT `fk_lis_det_lis` FOREIGN KEY (`id_lista`) REFERENCES `lista` (`id_lista`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `direccion`
--
ALTER TABLE `direccion`
  ADD CONSTRAINT `fk_per_dir` FOREIGN KEY (`id_datos_personales`) REFERENCES `datos_personales` (`id_datos_personales`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  ADD CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `hoja_asistencia`
--
ALTER TABLE `hoja_asistencia`
  ADD CONSTRAINT `fk_asamblea_hoja_asistencia` FOREIGN KEY (`id_asamblea`) REFERENCES `asamblea` (`id_asamblea`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `hoja_asistencia_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `lista`
--
ALTER TABLE `lista`
  ADD CONSTRAINT `fk_com_lis` FOREIGN KEY (`id_comite`) REFERENCES `comite` (`id_comite`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `multa_asistencia`
--
ALTER TABLE `multa_asistencia`
  ADD CONSTRAINT `fk_asi_mul_asi` FOREIGN KEY (`id_hoja_asistencia`) REFERENCES `hoja_asistencia` (`id_hoja_asistencia`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_asis` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `multa_limpia`
--
ALTER TABLE `multa_limpia`
  ADD CONSTRAINT `fk_det_lim_mul_lim` FOREIGN KEY (`id_det_limpia`) REFERENCES `det_limpieza` (`id_det_limpieza`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_mul_lim` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `multa_orden`
--
ALTER TABLE `multa_orden`
  ADD CONSTRAINT `fk_mul_mul_ord` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_ord` FOREIGN KEY (`id_orden`) REFERENCES `orden_riego` (`id_orden_riego`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `obra`
--
ALTER TABLE `obra`
  ADD CONSTRAINT `fk_can_obr` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `orden_riego`
--
ALTER TABLE `orden_riego`
  ADD CONSTRAINT `fk_par_ord` FOREIGN KEY (`id_parcela`) REFERENCES `parcela` (`id_parcela`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_rep_ord` FOREIGN KEY (`id_reparto`) REFERENCES `reparto` (`id_reparto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `parcela`
--
ALTER TABLE `parcela`
  ADD CONSTRAINT `fk_can_par` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `parcela_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
