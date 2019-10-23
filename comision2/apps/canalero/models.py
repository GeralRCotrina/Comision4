from django.db import models




"""
class Reparto(models.Model):
	Descripcion=models.CharField(max_length=50)
	Numero=models.PositiveSmallIntegerField()	
	FechaReparto=models.DateField()
	Estado=models.BooleanField(default=True)

	def __str__(self):
		return  "{0} ({1})".format(self.Descripcion,self.Numero)

"""







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


class Caudal(models.Model):
    id_caudal = models.AutoField(primary_key=True)
    id_canal = models.ForeignKey(Canal, models.DO_NOTHING, db_column='id_canal', blank=True, null=True)
    fecha = models.DateTimeField(blank=True, null=True)
    nivel = models.IntegerField(blank=True, null=True)
    descripcion = models.CharField(max_length=45, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'caudal'


class Comite(models.Model):
    id_comite = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=100, blank=True, null=True)
    descripcion = models.CharField(max_length=200, blank=True, null=True)
    fecha_creacion = models.DateTimeField(blank=True, null=True)
    estado = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'comite'
        
    def __str__(self):
        cadena = "[{0}] {1}"
        return cadena.format(self.id_canal,self.nombre)
