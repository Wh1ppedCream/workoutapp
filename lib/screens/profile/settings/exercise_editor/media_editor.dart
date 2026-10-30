part of '../exercise_editor_screen.dart';

extension _MediaEditor on _ExerciseEditorScreenState {
  String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  IconData _mediaIcon(String mediaType) {
    switch (mediaType) {
      case 'image':
        return Icons.image_outlined;
      case 'video':
        return Icons.play_circle_outline;
      default:
        return Icons.link;
    }
  }

  String _mediaLabel(ExerciseMediaItem item) {
    final title = _trimToNull(item.title);
    if (title != null) return title;
    final uri = Uri.tryParse(item.remoteUrl);
    final host = uri?.host;
    if (host != null && host.isNotEmpty) return host;
    return item.remoteUrl;
  }

  Future<ExerciseMediaItem?> _showMediaEditor({
    ExerciseMediaItem? initial,
  }) async {
    if (!mounted) return null;

    var remoteUrlValue = initial?.remoteUrl ?? '';
    var titleValue = initial?.title ?? '';
    var thumbnailUrlValue = initial?.thumbnailUrl ?? '';
    var mediaType = initial?.mediaType ?? 'image';
    final formKey = GlobalKey<FormState>();

    final result = await showTonosDialog<ExerciseMediaItem>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return TonosDialogFrame(
              styleFormControls: true,
              styleDarkNeoPickerSurfaces: true,
              child: AlertDialog(
                title: Text(
                  initial == null
                      ? _strings.exerciseEditorAddMedia
                      : _strings.exerciseEditorEditMedia,
                ),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: mediaType,
                          items: [
                            DropdownMenuItem(
                              value: 'image',
                              child: Text(_strings.exerciseEditorMediaImage),
                            ),
                            DropdownMenuItem(
                              value: 'video',
                              child: Text(_strings.exerciseEditorMediaVideo),
                            ),
                            DropdownMenuItem(
                              value: 'link',
                              child: Text(_strings.exerciseEditorMediaLink),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() => mediaType = value);
                          },
                          decoration: InputDecoration(
                            labelText: _strings.exerciseEditorMediaType,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TonosFormField(
                          initialValue: titleValue,
                          labelText: _strings.exerciseEditorMediaTitle,
                          hintText: _strings.exerciseEditorMediaTitleHint,
                          onChanged: (value) => titleValue = value,
                        ),
                        const SizedBox(height: 12),
                        TonosFormField(
                          initialValue: remoteUrlValue,
                          labelText: _strings.exerciseEditorMediaRemoteUrl,
                          hintText: 'https://...',
                          onChanged: (value) => remoteUrlValue = value,
                          validator: (value) => _trimToNull(value) == null
                              ? _strings.exerciseEditorMediaUrlRequired
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TonosFormField(
                          initialValue: thumbnailUrlValue,
                          labelText: _strings.exerciseEditorMediaThumbnailUrl,
                          hintText: _strings.exerciseEditorMediaThumbnailHint,
                          onChanged: (value) => thumbnailUrlValue = value,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(_strings.commonCancel),
                  ),
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() != true) return;
                      final remoteUrl = _trimToNull(remoteUrlValue);
                      if (remoteUrl == null) return;
                      Navigator.of(ctx).pop(
                        ExerciseMediaItem(
                          id: initial?.id,
                          exerciseDefId:
                              initial?.exerciseDefId ?? _selectedDef?.id ?? -1,
                          mediaType: mediaType,
                          remoteUrl: remoteUrl,
                          thumbnailUrl: _trimToNull(thumbnailUrlValue),
                          localCachePath: initial?.localCachePath,
                          localThumbnailPath: initial?.localThumbnailPath,
                          title: _trimToNull(titleValue),
                          sortOrder: initial?.sortOrder ?? _mediaItems.length,
                        ),
                      );
                    },
                    child: Text(_strings.commonSave),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    return result;
  }

  Future<void> _openAddMediaDialog() async {
    if (_selectedDef == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.exerciseEditorSelectBeforeMedia)),
      );
      return;
    }

    final created = await _showMediaEditor();
    if (created == null) return;

    _updateEditorState(() {
      _mediaItems.add(
        created.copyWith(
          exerciseDefId: _selectedDef!.id,
          sortOrder: _mediaItems.length,
        ),
      );
      _hasPendingChanges = true;
    });
  }

  Future<void> _editMediaItem(int index) async {
    final updated = await _showMediaEditor(initial: _mediaItems[index]);
    if (updated == null) return;

    _updateEditorState(() {
      _mediaItems[index] = updated.copyWith(
        exerciseDefId: _selectedDef?.id ?? updated.exerciseDefId,
        sortOrder: index,
      );
      _hasPendingChanges = true;
    });
  }

  Widget _buildNotesMediaTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditorInfoCard(
          icon: Icons.menu_book_outlined,
          title: _strings.exerciseEditorFormGuide,
          body: _strings.exerciseEditorFormGuideBody,
          iconColor: SettingsAccent.advanced,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: _strings.exerciseEditorGuidance,
          subtitle: _isEditing
              ? _strings.exerciseEditorGuidanceEditing
              : _strings.exerciseEditorGuidanceReadOnly,
          accentColor: _usesExpressive
              ? _expressiveIdentitySurface(3)
              : SettingsAccent.advanced,
          titleColor: _usesExpressive
              ? _expressiveIdentityHeadingColor(3)
              : null,
          children: [
            _buildGuideField(
              controller: _setupController,
              label: _strings.exerciseEditorSetUp,
              hint: _strings.exerciseEditorSetUpHint,
            ),
            _buildGuideField(
              controller: _executionController,
              label: _strings.exerciseEditorHowToPerform,
              hint: _strings.exerciseEditorHowToPerformHint,
            ),
            _buildGuideField(
              controller: _tipsController,
              label: _strings.exerciseEditorCoachingTips,
              hint: _strings.exerciseEditorCoachingTipsHint,
            ),
          ],
        ),
        _buildEditorInfoCard(
          icon: Icons.cloud_sync_outlined,
          title: _strings.exerciseEditorReferenceMedia,
          body: _strings.exerciseEditorReferenceMediaBody,
          iconColor: SettingsAccent.data,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: _strings.exerciseEditorMediaLinks,
          subtitle: _isEditing
              ? _strings.exerciseEditorMediaLinksEditing
              : _strings.exerciseEditorMediaLinksCount(_mediaItems.length),
          accentColor: _usesExpressive
              ? _expressiveIdentitySurface(3)
              : SettingsAccent.data,
          titleColor: _usesExpressive
              ? _expressiveIdentityHeadingColor(3)
              : null,
          children: [
            if (_mediaItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(_strings.exerciseEditorNoReferenceMedia),
              )
            else
              for (var index = 0; index < _mediaItems.length; index++)
                _buildMediaTile(index),
            if (_isEditing)
              _editorInlineAddAction(
                onPressed: _openAddMediaDialog,
                label: _strings.exerciseEditorAddMediaLink,
                identityIndex: 3,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuideField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    final theme = Theme.of(context);
    if (_usesExpressive && !_isEditing) {
      final value = controller.text.trim();
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF202927)
                    : const Color(0xFFFFFCF8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.32,
                  ),
                ),
              ),
              child: Text(
                value.isEmpty ? hint : value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: value.isEmpty
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final decoration = settingsFieldDecoration(
      context,
      label: _usesExpressive ? '' : label,
      hint: hint,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _usesExpressive ? 12 : 14,
        _usesExpressive ? 8 : 12,
        _usesExpressive ? 12 : 14,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_usesExpressive) ...[
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Semantics(
            label: _usesExpressive ? label : null,
            child: TextField(
              controller: controller,
              readOnly: !_isEditing,
              minLines: 3,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: _usesExpressive ? theme.textTheme.bodyMedium : null,
              decoration: _usesExpressive
                  ? InputDecoration(
                      hintText: hint,
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark
                          ? const Color(0xFF202927)
                          : const Color(0xFFFFFCF8),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.32,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.32,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _expressiveHeroColor,
                          width: 1.5,
                        ),
                      ),
                    )
                  : decoration,
              onChanged: _isEditing ? (_) => _markChanged() : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTile(int index) {
    final item = _mediaItems[index];
    return SettingsActionTile(
      icon: _mediaIcon(item.mediaType),
      iconColor: SettingsAccent.data,
      title: _mediaLabel(item),
      subtitle: _strings.exerciseEditorMediaReference(
        _localizedMediaType(item.mediaType),
      ),
      onTap: _isEditing ? () => _editMediaItem(index) : null,
      compact: _usesExpressive,
      compactVerticalPadding: 3,
      trailing: _isEditing
          ? IconButton(
              tooltip: _strings.exerciseEditorRemoveMedia,
              onPressed: () async {
                if (!await _confirmRemove(
                  _mediaLabel(item),
                  _strings.exerciseEditorMediaLinkItem,
                )) {
                  return;
                }
                _updateEditorState(() {
                  _mediaItems.removeAt(index);
                  _hasPendingChanges = true;
                });
              },
              icon: const Icon(Icons.delete_outline),
            )
          : Text(
              item.mediaType.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium,
            ),
    );
  }

  String _localizedMediaType(String mediaType) {
    switch (mediaType) {
      case 'image':
        return _strings.exerciseEditorMediaImage;
      case 'video':
        return _strings.exerciseEditorMediaVideo;
      default:
        return _strings.exerciseEditorMediaLink;
    }
  }
}
