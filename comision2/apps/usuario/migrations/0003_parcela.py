# Generated by Django 2.1.1 on 2018-09-14 03:25

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('usuario', '0002_auto_20180912_1116'),
    ]

    operations = [
        migrations.CreateModel(
            name='Parcela',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('NombreP', models.CharField(max_length=50)),
                ('Ubicacion', models.CharField(max_length=100)),
                ('NumeroToma', models.CharField(max_length=3)),
                ('HasTotal', models.CharField(max_length=3)),
                ('HasSembradas', models.CharField(max_length=3)),
                ('Usuario', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='usuario.Usuario')),
            ],
        ),
    ]
