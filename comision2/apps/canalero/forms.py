from django import forms
from apps.inicio.models import Reparto, Multa, Destajo, Limpieza
from django.forms import DateTimeField


class LimpiezaForm(forms.ModelForm):

	class Meta:
		model = Limpieza
		
		fields = ['id_limpieza','decripcion','tipo','fecha_limpieza','fecha_revision','hora_revision','estado']	

		labels = {
			'decripcion':'Breve descripción',
			'tipo':'Tipo de limpieza',
			'fecha_limpieza':'Fecha de inicio',
			'fecha_revision':'Fecha de revisión',
			'hora_revision':'Hora de revisión',
			'estado':'Estado',
		}

		widgets={	
				'decripcion':forms.Textarea(attrs={'class':'form-control','rows':'5'}),
			    'tipo':forms.Select(attrs={'class':'form-control'}),
			    'fecha_limpieza':forms.DateTimeInput(attrs={'class':'form-control col-7','placeholder':'dd/mm/aaaa','type':'date'}),
			    'fecha_revision':forms.DateTimeInput(attrs={'class':'form-control col-7','placeholder':'dd/mm/aaaa','type':'date'}),
			    'hora_revision':forms.TimeInput(attrs={'class':'form-control col-7','type':'time'}),
			    'estado':forms.Select(attrs={'class':'form-control col-7'}),
		    }


class RepartoForm(forms.ModelForm):

	class Meta:
		model = Reparto
		
		fields = ['id_reparto','descripcion','tipo','fecha_registro','fecha_reparto','hora_reparto','estado']	

		labels = {
			'descripcion':'Breve descripción',
			'tipo':'Tipo de reparto',
			'fecha_registro':'Fecha de registro',
			'fecha_reparto':'Fecha de entrega de órdenes',
			'hora_reparto':'Hora de reparto',
			'estado':'Estado',
		}

		widgets={	
				'descripcion':forms.Textarea(attrs={'class':'form-control','rows':'5'}),
			    'tipo':forms.Select(attrs={'class':'form-control'}),
			    'fecha_registro':forms.DateTimeInput(attrs={'class':'form-control col-7','type':'date'}),
			    'fecha_reparto':forms.DateTimeInput(attrs={'class':'form-control col-7','type':'date'}),
			    'hora_reparto':forms.TimeInput(attrs={'class':'form-control col-7','type':'time'}),
			    'estado':forms.Select(attrs={'class':'form-control col-7'}),
		    }





class DestajoForm(forms.ModelForm):

	class Meta:
		model = Destajo

		fields = ['id_destajo','id_canal','id_parcela','tamano','num_orden','descripcion','fecha_registro','estado']	

		labels = {
			'id_canal':'Seleccione el canal en el que se ubica',
			'id_parcela':'La parcela a la que corresponde',
			'tamano':'Tamaño en metros',
			'num_orden':'Número de orden en el canal',
			'descripcion':'Descripción',
			'fecha_registro':'Fecha registro',
			'estado':'Estado'
		}

		widgets={	
				'id_canal':forms.Select(attrs={'class':'form-control'}),
			    'id_parcela':forms.Select(attrs={'class':'form-control'}),
			    'tamano':forms.TextInput(attrs={'class':'form-control'}),
			    'num_orden':forms.TextInput(attrs={'class':'form-control'}),
			    'descripcion':forms.TextInput(attrs={'class':'form-control'}),
			    'fecha_registro':forms.DateInput(attrs={'class':'form-control'}),
			    'estado':forms.Select(attrs={'class':'form-control col-7'}),
		    }


class MultaForm(forms.ModelForm):

	class Meta:
		model = Multa

		fields = ['id_multa','concepto','fecha','estado','tipo',]	

		labels = {
			'concepto':'Concepto de la multa',
			'fecha':'Fecha de emisión',
			'estado':'Estado de la Multa',
			'tipo':'Tipo de la Multa',
		}

		widgets={
			    'concepto':forms.Textarea(attrs={'class':'form-control','rows':'5'}),
			    'fecha':forms.DateInput(attrs={'class':'form-control col-7','type':'date'}),
			    'estado':forms.Select(attrs={'class':'form-control col-7'}),
			    'tipo':forms.Select(attrs={'class':'form-control col-7'}),
		    }
