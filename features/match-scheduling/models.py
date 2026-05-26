from django.db import models
from teams.models import Team


class Match(models.Model):
    STATUS_SCHEDULED = 'scheduled'
    STATUS_LIVE = 'live'
    STATUS_COMPLETED = 'completed'

    STATUS_CHOICES = [
        (STATUS_SCHEDULED, 'Scheduled'),
        (STATUS_LIVE, 'Live'),
        (STATUS_COMPLETED, 'Completed'),
    ]

    home_team = models.ForeignKey(
        Team, on_delete=models.CASCADE, related_name='home_matches'
    )
    away_team = models.ForeignKey(
        Team, on_delete=models.CASCADE, related_name='away_matches'
    )
    date = models.DateTimeField()
    home_score = models.PositiveIntegerField(null=True, blank=True)
    away_score = models.PositiveIntegerField(null=True, blank=True)
    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default=STATUS_SCHEDULED
    )

    class Meta:
        ordering = ['-date']

    def __str__(self):
        return f"{self.home_team} vs {self.away_team} ({self.date.date()})"
