import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/injection.dart';
import '../../core/services/notification_service.dart';
import '../../l10n/app_localizations.dart';

/// Settings Page - Bildirim ve ses ayarları
/// PRT-006: Ezan ses kütüphanesi seçimi

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final NotificationService _notificationService = getIt<NotificationService>();
  
  AzanSound _selectedSound = AzanSound.istanbul;
  int _preAlarmMinutes = 15;
  bool _notificationsEnabled = true;
  bool _preAlarmEnabled = true;
  bool _wifiOnlyEnabled = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final sound = await _notificationService.getPreferredSound();
    final preAlarm = await _notificationService.getPreAlarmMinutes();
    
    setState(() {
      _selectedSound = sound;
      _preAlarmMinutes = preAlarm;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _preAlarmEnabled = prefs.getBool('pre_alarm_enabled') ?? true;
      _wifiOnlyEnabled = prefs.getBool('download_wifi_only') ?? true;
    });
  }
  
  Future<void> _saveNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
    if (!value) {
      _notificationService.cancelAll();
    }
  }
  
  Future<void> _savePreAlarmEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pre_alarm_enabled', value);
    setState(() => _preAlarmEnabled = value);
  }

  Future<void> _saveWifiOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('download_wifi_only', value);
    setState(() => _wifiOnlyEnabled = value);
  }
  
  Future<void> _saveSound(AzanSound sound) async {
    await _notificationService.setPreferredSound(sound);
    setState(() => _selectedSound = sound);
  }
  
  Future<void> _savePreAlarmMinutes(int minutes) async {
    await _notificationService.setPreAlarmMinutes(minutes);
    setState(() => _preAlarmMinutes = minutes);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings_title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications Section
          _buildSectionHeader('Bildirimler', Icons.notifications_rounded),
          _buildSwitchTile(
            title: 'Namaz Vakti Bildirimleri',
            subtitle: 'Ezan vakti geldiğinde bildirim al',
            value: _notificationsEnabled,
            onChanged: _saveNotificationsEnabled,
          ),
          _buildSwitchTile(
            title: 'Vakit Hatırlatıcısı',
            subtitle: 'Namaz vaktinden önce uyar',
            value: _preAlarmEnabled,
            onChanged: _savePreAlarmEnabled,
          ),
          if (_preAlarmEnabled) _buildPreAlarmSelector(),
          
          const Divider(height: 32),
          
          // Sound Section
          _buildSectionHeader('Ezan Sesi', Icons.music_note_rounded),
          _buildSoundSelector(),
          
          const Divider(height: 32),

          // Downloads Section
          _buildSectionHeader('İndirmeler', Icons.download_rounded),
          _buildSwitchTile(
            title: 'Sadece Wi-Fi ile İndir',
            subtitle: 'Mobil veri kullanımını önlemek için',
            value: _wifiOnlyEnabled,
            onChanged: _saveWifiOnly,
          ),
          
          const Divider(height: 32),
          
          // General Section
          _buildSectionHeader('Genel', Icons.settings_rounded),
          _buildListTile(
            title: loc.settings_language,
            subtitle: 'Türkçe',
            icon: Icons.language_rounded,
            onTap: () {
              // TODO: Dil seçimi dialog
            },
          ),
          _buildListTile(
            title: loc.settings_theme,
            subtitle: loc.settings_theme_auto,
            icon: Icons.palette_rounded,
            onTap: () {
              // TODO: Tema seçimi dialog
            },
          ),
          
          const Divider(height: 32),
          
          // About Section
          _buildSectionHeader('Hakkında', Icons.info_rounded),
          _buildListTile(
            title: loc.settings_privacy,
            icon: Icons.privacy_tip_rounded,
            onTap: () {},
          ),
          _buildListTile(
            title: loc.settings_terms,
            icon: Icons.description_rounded,
            onTap: () {},
          ),
          _buildListTile(
            title: 'Versiyon',
            subtitle: '1.0.0',
            icon: Icons.verified_rounded,
            onTap: () {},
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }
  
  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildPreAlarmSelector() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hatırlatma Süresi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [5, 10, 15, 30].map((minutes) {
                final isSelected = _preAlarmMinutes == minutes;
                return ChoiceChip(
                  label: Text('$minutes dk'),
                  selected: isSelected,
                  onSelected: (_) => _savePreAlarmMinutes(minutes),
                  selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryGreen : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSoundSelector() {
    final sounds = {
      AzanSound.istanbul: ('İstanbul Makamı', 'Türkiye\'de en çok kullanılan'),
      AzanSound.mecca: ('Mekke Ezanı', 'Harem-i Şerif usulü'),
      AzanSound.medina: ('Medine Ezanı', 'Mescid-i Nebevi usulü'),
      AzanSound.ney: ('Ney Sesi', 'Sakin ve huzurlu'),
      AzanSound.silent: ('Sessiz', 'Sadece titreşim'),
    };
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: sounds.entries.map((entry) {
          final isSelected = _selectedSound == entry.key;
          return RadioListTile<AzanSound>(
            title: Text(entry.value.$1),
            subtitle: Text(entry.value.$2),
            value: entry.key,
            groupValue: _selectedSound,
            onChanged: (value) {
              if (value != null) _saveSound(value);
            },
            activeColor: AppTheme.primaryGreen,
            secondary: isSelected 
                ? Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                : null,
          );
        }).toList(),
      ),
    );
  }
}
