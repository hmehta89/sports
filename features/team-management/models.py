from django.db import models


class Team(models.Model):
    name = models.CharField(max_length=100, unique=True)
    city = models.CharField(max_length=100)
    sport = models.CharField(max_length=50)
    founded_year = models.PositiveIntegerField()

    class Meta:
        ordering = ['name']

    def __str__(self):
        return f"{self.city} {self.name}"
