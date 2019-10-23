#from django.db import models

# Create your models here.
 


from django.db import models


from django.utils.translation import ugettext as _


from datetime import datetime
def get_date_now():
    return datetime.now().strftime("%Y-%m-%d")



def get_hour_now():
    return datetime.now().strftime("%H:%M:%S")



def get_hour_rep():
    return datetime.now().strftime("16:30:00")



 




class AgendaAsamblea(models.Model):
    id_agenda = models.AutoField(primary_key=True)
    id_asamblea = models.ForeignKey('Asamblea', models.DO_NOTHING, db_column='id_asamblea', blank=True, null=True)
    punto_numero = models.IntegerField(blank=True, null=True)
    descripcion = models.CharField(max_length=400, blank=True, null=True)
    foto = models.CharField(max_length=150, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'agenda_asamblea'



class Asamblea(models.Model):
    TIPO = (
        ('General', 'REUNIÓN GENERAL'),
        ('Simple', 'REUNIÓN SIMPLE'),
    )
    ESTADO = (
        ('1', 'CREADA'),
        ('2', 'INICIADA'),
        ('3', 'TERMINADA'),
        ('4', 'CANCELADA'),
    )
    id_asamblea = models.AutoField(primary_key=True)
    tipo = models.CharField(max_length=15, blank=True, null=True, choices=TIPO)
    descripcion = models.CharField(max_length=300, blank=True, null=True)
    fecha_registro = models.DateTimeField(blank=True, null=True)
    fecha_asamblea = models.DateTimeField(blank=True, null=True)
    estado = models.CharField(max_length=15, blank=True, null=True,choices=ESTADO)

    class Meta:
        managed = False
        db_table = 'asamblea'
