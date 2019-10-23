
from django.db import models


from datetime import datetime
def get_date_now():
    return datetime.now().strftime("%Y-%m-%d")

def get_hour_now():
    return datetime.now().strftime("%H:%M:%S")

def get_hour_rep():
    return datetime.now().strftime("16:30:00")



class Canal(models.Model):
    id_canal = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=45, blank=True, null=True)
    tamano = models.FloatField(blank=True, null=True)
    ubicacion = models.CharField(max_length=45, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'canal'

    def __str__(self):
        cadena="{0}"
        return cadena.format(self.nombre)



class AuthUser(models.Model):
    SEXO = (
        ('M', 'MASCULINO'),
        ('F', 'FEMENINO'),
    )
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.IntegerField(default=0)
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254, blank=True, null=True)
    is_staff = models.IntegerField(default=0)
    is_active = models.IntegerField(default=1)
    date_joined = models.DateTimeField(default="2000-01-01 10:00:01")
    dni = models.CharField(max_length=8)
    foto = models.ImageField(upload_to='photos',blank=True, null=True)
    sexo = models.CharField(max_length=1, blank=True, null=True, choices=SEXO)
    fecha_nacimiento = models.DateField(blank=True, null=True)
    telefono = models.IntegerField(blank=True, null=True)
    celular = models.IntegerField(blank=True, null=True)
    alias = models.CharField(max_length=30, blank=True, null=True)


class Parcela(models.Model):
    ESTADO = (
        ('0', 'REGISTRADA'),
        ('1', 'ACTIVA'),
        ('2', 'NEGADA'),
    )
    id_parcela = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=60, blank=True, null=True)
    codigo_predio = models.CharField(max_length=25, blank=True, null=True)
    ubicacion = models.CharField(max_length=150, blank=True, null=True)
    num_toma = models.IntegerField(blank=True, null=True)
    id_canal = models.ForeignKey(Canal, models.DO_NOTHING, db_column='id_canal', blank=True, null=True)
    id_auth_user = models.ForeignKey(AuthUser, models.DO_NOTHING, db_column='id_auth_user', blank=True, null=True)
    total_has = models.FloatField(blank=True, null=True)
    has_sembradas = models.FloatField(blank=True, null=True)
    descripcion = models.CharField(max_length=100, blank=True, null=True)
    estado = models.CharField(max_length=15, blank=True, null=True, choices=ESTADO)
    volumen_agua = models.FloatField(blank=True, null=True)
    

    class Meta:
        managed = False
        db_table = 'parcela'

    def __str__(self):
        cadena = "{0} - ubicada en {1}"
        return cadena.format(self.nombre, self.ubicacion)


class Reparto(models.Model):
    TIPO = (
        ('Para Chayas', 'Para Chayas '),
        ('General', 'General'),
        ('Especial', 'Especial'),
    )
    ESTADO = (
        ('1', 'CREADO'),
        ('2', 'APERTURADO'),
        ('3', 'EMITIDO'),
        ('4', 'CERRADO'),
    )
    id_reparto = models.AutoField(primary_key=True)
    descripcion = models.CharField(max_length=500, blank=True, null=True)
    tipo = models.CharField(max_length=15, blank=True, null=True, choices=TIPO)
    fecha_registro = models.DateField(default=get_date_now)
    fecha_reparto = models.DateField(default=get_date_now)
    hora_reparto = models.TimeField(default=get_hour_now)
    estado = models.CharField(max_length=1, blank=True, null=True, choices=ESTADO)

    class Meta:
        managed = False
        db_table = 'reparto'

    def __str__(self):
        cadena = "[{0}] {1} - {2}"
        return cadena.format(self.id_reparto,self.tipo, self.fecha_reparto)

class Talonario(models.Model):
    id_talonario = models.AutoField(primary_key=True)
    codigo = models.IntegerField(blank=True, null=True)
    descripcion = models.CharField(max_length=150, blank=True, null=True)
    primer_ticket = models.IntegerField(blank=True, null=True)
    cantidad_tickets = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'talonario'








