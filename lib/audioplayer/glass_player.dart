import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:provider/provider.dart';

import '../components/artwork_async.dart';
import '../components/glass.dart';
import '../model/track.dart';
import '../utils/track_utils.dart';
import 'audio_player.dart';
import 'player_math.dart';

/// Floating "glass" player shown at the bottom of the content area.
///
/// Stays out of the way (hidden and not hit-testable) until something has been
/// queued, then slides in. Adapts [AudioPlayer] to a [GlassPlayerView].
class GlassPlayerBar extends StatelessWidget {
  static const double kHeight = 66;

  /// Room to leave at the bottom of scrollable content so that nothing gets
  /// stuck behind the player.
  static const double kContentInset = 112;

  const GlassPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayer>(
      builder: (context, audioPlayer, child) {
        final bool visible = !audioPlayer.isStopped;
        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            offset: visible ? Offset.zero : const Offset(0, 1.6),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: visible ? 1 : 0,
              child: StreamBuilder<Track?>(
                stream: audioPlayer.currentTrackStream,
                builder: (context, snapshot) => GlassPlayerView(
                  track: snapshot.data,
                  artwork: AsyncArtwork(
                    track: snapshot.data,
                    size: 44,
                    radius: 8,
                    placeholder: const _ArtworkPlaceholder(),
                  ),
                  playing: audioPlayer.isPlaying,
                  canPrevious: audioPlayer.canPrevious,
                  canNext: audioPlayer.canNext,
                  shuffle: audioPlayer.shuffleEnabled,
                  repeat: audioPlayer.repeatMode,
                  volume: audioPlayer.volume,
                  progress: audioPlayer.progressStream,
                  onPlayPause: audioPlayer.playpause,
                  onPrevious: audioPlayer.previous,
                  onNext: audioPlayer.next,
                  onShuffle: audioPlayer.toggleShuffle,
                  onRepeat: audioPlayer.cycleRepeat,
                  onSeek: audioPlayer.seekTo,
                  onVolume: audioPlayer.setVolume,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0x22808080),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        CupertinoIcons.music_note_2,
        size: 20,
        color: Color(0x88808080),
      ),
    );
  }
}

/// Stateless rendering of the player so that it can be driven by anything.
class GlassPlayerView extends StatelessWidget {
  static const double _kMaxWidth = 780;
  static const double _kCompactWidth = 600;

  final Track? track;
  final Widget artwork;
  final bool playing;
  final bool canPrevious;
  final bool canNext;
  final bool shuffle;
  final PlayerRepeat repeat;
  final double volume;
  final Stream<double?> progress;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onVolume;

  const GlassPlayerView({
    super.key,
    required this.track,
    required this.artwork,
    required this.playing,
    required this.canPrevious,
    required this.canNext,
    required this.shuffle,
    required this.repeat,
    required this.volume,
    required this.progress,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onShuffle,
    required this.onRepeat,
    required this.onSeek,
    required this.onVolume,
  });

  @override
  Widget build(BuildContext context) {
    final _Palette palette = _Palette.of(glassBrightness(context));
    return LayoutBuilder(
      builder: (context, constraints) {
        final double available =
            constraints.hasBoundedWidth ? constraints.maxWidth : _kMaxWidth;
        final double width = (available - 48).clamp(320.0, _kMaxWidth);
        final bool compact = width < _kCompactWidth;
        return Center(
          widthFactor: 1,
          heightFactor: 1,
          child: SizedBox(
            width: width,
            height: GlassPlayerBar.kHeight,
            child: GlassSurface(
              radius: GlassPlayerBar.kHeight / 2,
              padding: EdgeInsets.fromLTRB(11, 0, compact ? 20 : 22, 0),
              child: Row(
                children: [
                  _transport(palette, compact),
                  const SizedBox(width: 14),
                  Expanded(child: _nowPlaying(palette)),
                  if (!compact) ...[
                    const SizedBox(width: 18),
                    _VolumeControl(
                      volume: volume,
                      palette: palette,
                      onChanged: onVolume,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _transport(_Palette p, bool compact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact)
          _PlayerButton(
            icon: CupertinoIcons.shuffle,
            label: 'Shuffle',
            size: 14,
            color: shuffle ? p.accent : p.muted,
            onPressed: onShuffle,
            palette: p,
          ),
        _PlayerButton(
          icon: CupertinoIcons.backward_fill,
          label: 'Previous track',
          size: 20,
          color: canPrevious ? p.foreground : p.disabled,
          onPressed: canPrevious ? onPrevious : null,
          palette: p,
        ),
        _PlayerButton(
          icon: playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
          label: playing ? 'Pause' : 'Play',
          size: 26,
          extent: 40,
          color: p.foreground,
          onPressed: onPlayPause,
          palette: p,
        ),
        _PlayerButton(
          icon: CupertinoIcons.forward_fill,
          label: 'Next track',
          size: 20,
          color: canNext ? p.foreground : p.disabled,
          onPressed: canNext ? onNext : null,
          palette: p,
        ),
        if (!compact)
          _PlayerButton(
            icon: repeat == PlayerRepeat.one
                ? CupertinoIcons.repeat_1
                : CupertinoIcons.repeat,
            label: 'Repeat',
            size: 14,
            color: repeat == PlayerRepeat.off ? p.muted : p.accent,
            onPressed: onRepeat,
            palette: p,
          ),
      ],
    );
  }

  Widget _nowPlaying(_Palette p) {
    final Track? t = track;
    final String title = t?.displayTitle ?? '';
    final String subtitle =
        t == null ? '' : '${t.displayPerformer} — ${t.displayAlbum}';
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(width: 44, height: 44, child: artwork),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: p.foreground,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.25,
                  color: p.muted,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 3),
              _ScrubBar(
                progress: progress,
                durationSeconds: t?.safeTags.duration ?? 0,
                palette: p,
                onSeek: onSeek,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Seek bar: thin at rest, grows under the pointer and reveals the times.
class _ScrubBar extends StatefulWidget {
  final Stream<double?> progress;
  final int durationSeconds;
  final ValueChanged<double> onSeek;
  final _Palette palette;

  const _ScrubBar({
    required this.progress,
    required this.durationSeconds,
    required this.onSeek,
    required this.palette,
  });

  @override
  State<_ScrubBar> createState() => _ScrubBarState();
}

class _ScrubBarState extends State<_ScrubBar> {
  bool _hovered = false;
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final _Palette p = widget.palette;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: StreamBuilder<double?>(
        stream: widget.progress,
        builder: (context, snapshot) {
          final double value = _dragValue ??
              clampDouble(snapshot.hasData ? (snapshot.data ?? 0) : 0, 0, 1);
          final int elapsed = (value * widget.durationSeconds).round();
          final int remaining = widget.durationSeconds - elapsed;
          final bool active = _hovered || _dragValue != null;
          final TextStyle time = TextStyle(
            fontSize: 10.5,
            height: 1,
            color: p.muted,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w400,
            fontFeatures: const [FontFeature.tabularFigures()],
          );
          return Row(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: active ? 1 : 0,
                child: SizedBox(
                  width: 34,
                  child: Text(formatClock(elapsed), style: time),
                ),
              ),
              Expanded(
                child: _SliderBar(
                  value: value,
                  palette: p,
                  active: active,
                  onChanged: (v) => setState(() => _dragValue = v),
                  onChangeEnd: (v) {
                    widget.onSeek(v);
                    setState(() => _dragValue = null);
                  },
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: active ? 1 : 0,
                child: SizedBox(
                  width: 38,
                  child: Text(
                    '-${formatClock(remaining)}',
                    textAlign: TextAlign.right,
                    style: time,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VolumeControl extends StatefulWidget {
  final double volume;
  final _Palette palette;
  final ValueChanged<double> onChanged;
  const _VolumeControl({
    required this.volume,
    required this.palette,
    required this.onChanged,
  });

  @override
  State<_VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<_VolumeControl> {
  bool _hovered = false;
  double _beforeMute = 1.0;

  @override
  Widget build(BuildContext context) {
    final _Palette p = widget.palette;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlayerButton(
            icon: volumeIcon(widget.volume),
            label: widget.volume <= 0 ? 'Unmute' : 'Mute',
            size: 17,
            color: p.foreground,
            palette: p,
            onPressed: () {
              if (widget.volume > 0) {
                _beforeMute = widget.volume;
                widget.onChanged(0);
              } else {
                widget.onChanged(_beforeMute);
              }
            },
          ),
          SizedBox(
            width: 76,
            child: _SliderBar(
              value: widget.volume,
              palette: p,
              active: _hovered,
              onChanged: widget.onChanged,
              onChangeEnd: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin horizontal slider shared by the scrubber and the volume control.
class _SliderBar extends StatelessWidget {
  final double value;
  final bool active;
  final _Palette palette;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _SliderBar({
    required this.value,
    required this.active,
    required this.palette,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        double fraction(Offset local) => fractionForDx(local.dx, width);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => onChangeEnd(fraction(d.localPosition)),
          onHorizontalDragStart: (d) => onChanged(fraction(d.localPosition)),
          onHorizontalDragUpdate: (d) => onChanged(fraction(d.localPosition)),
          onHorizontalDragEnd: (_) => onChangeEnd(value),
          child: SizedBox(
            height: 14,
            child: Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  height: active ? 5 : 3,
                  decoration: BoxDecoration(
                    color: palette.track,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  height: active ? 5 : 3,
                  width: width * value,
                  decoration: BoxDecoration(
                    color: palette.fill,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Positioned(
                  left: width * value - 5,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: active ? 1 : 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.fill,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayerButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final double size;
  final double extent;
  final Color color;
  final VoidCallback? onPressed;
  final _Palette palette;

  const _PlayerButton({
    required this.icon,
    required this.label,
    required this.size,
    required this.color,
    required this.onPressed,
    required this.palette,
    this.extent = 32,
  });

  @override
  State<_PlayerButton> createState() => _PlayerButtonState();
}

class _PlayerButtonState extends State<_PlayerButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    return Tooltip(
      message: widget.label,
      waitDuration: const Duration(milliseconds: 600),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.label,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: widget.extent,
              height: widget.extent,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hovered && enabled
                    ? widget.palette.hover
                    : const Color(0x00000000),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 100),
                scale: _pressed ? 0.88 : 1,
                child:
                    Icon(widget.icon, size: widget.size, color: widget.color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Foreground colors used on top of the glass.
class _Palette {
  final Color foreground;
  final Color muted;
  final Color disabled;
  final Color accent;
  final Color track;
  final Color fill;
  final Color hover;

  const _Palette({
    required this.foreground,
    required this.muted,
    required this.disabled,
    required this.accent,
    required this.track,
    required this.fill,
    required this.hover,
  });

  static const _Palette light = _Palette(
    foreground: Color(0xFF1D1D1F),
    muted: Color(0xFF5E5E63),
    disabled: Color(0x661D1D1F),
    accent: CupertinoColors.systemBlue,
    track: Color(0x24000000),
    fill: Color(0xFF1D1D1F),
    hover: Color(0x14000000),
  );

  static const _Palette dark = _Palette(
    foreground: Color(0xFFF5F5F7),
    muted: Color(0xFFB4B4BC),
    disabled: Color(0x66F5F5F7),
    accent: Color(0xFF64A8FF),
    track: Color(0x40FFFFFF),
    fill: Color(0xFFF5F5F7),
    hover: Color(0x1FFFFFFF),
  );

  static _Palette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
