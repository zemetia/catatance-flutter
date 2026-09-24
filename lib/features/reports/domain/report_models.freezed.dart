// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategorySpending {

 int get categoryId; String get name; String get icon; int get colorValue; int get totalCents; double get share; int get count;
/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySpendingCopyWith<CategorySpending> get copyWith => _$CategorySpendingCopyWithImpl<CategorySpending>(this as CategorySpending, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategorySpending;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySpending&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.colorValue, _this.colorValue) || other.colorValue == _this.colorValue)&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents)&&(identical(other.share, _this.share) || other.share == _this.share)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as CategorySpending;
  return Object.hash(runtimeType,_this.categoryId,_this.name,_this.icon,_this.colorValue,_this.totalCents,_this.share,_this.count);
}

@override
String toString() {
  final _this = this as CategorySpending;
  return 'CategorySpending(categoryId: ${_this.categoryId}, name: ${_this.name}, icon: ${_this.icon}, colorValue: ${_this.colorValue}, totalCents: ${_this.totalCents}, share: ${_this.share}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $CategorySpendingCopyWith<$Res>  {
  factory $CategorySpendingCopyWith(CategorySpending value, $Res Function(CategorySpending) _then) = _$CategorySpendingCopyWithImpl;
@useResult
$Res call({
 int categoryId, String name, String icon, int colorValue, int totalCents, double share, int count
});




}
/// @nodoc
class _$CategorySpendingCopyWithImpl<$Res>
    implements $CategorySpendingCopyWith<$Res> {
  _$CategorySpendingCopyWithImpl(this._self, this._then);

  final CategorySpending _self;
  final $Res Function(CategorySpending) _then;

/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? name = null,Object? icon = null,Object? colorValue = null,Object? totalCents = null,Object? share = null,Object? count = null,}) {
  return _then(CategorySpending(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CategorySpending].
extension CategorySpendingPatterns on CategorySpending {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorySpending value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorySpending value)  $default,){
final _that = this;
switch (_that) {
case _CategorySpending():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorySpending value)?  $default,){
final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int categoryId,  String name,  String icon,  int colorValue,  int totalCents,  double share,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
return $default(_that.categoryId,_that.name,_that.icon,_that.colorValue,_that.totalCents,_that.share,_that.count);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int categoryId,  String name,  String icon,  int colorValue,  int totalCents,  double share,  int count)  $default,) {final _that = this;
switch (_that) {
case _CategorySpending():
return $default(_that.categoryId,_that.name,_that.icon,_that.colorValue,_that.totalCents,_that.share,_that.count);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int categoryId,  String name,  String icon,  int colorValue,  int totalCents,  double share,  int count)?  $default,) {final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
return $default(_that.categoryId,_that.name,_that.icon,_that.colorValue,_that.totalCents,_that.share,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _CategorySpending implements CategorySpending {
  const _CategorySpending({required this.categoryId, required this.name, required this.icon, required this.colorValue, required this.totalCents, required this.share, required this.count});
  

@override final  int categoryId;
@override final  String name;
@override final  String icon;
@override final  int colorValue;
@override final  int totalCents;
@override final  double share;
@override final  int count;

/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySpendingCopyWith<_CategorySpending> get copyWith => __$CategorySpendingCopyWithImpl<_CategorySpending>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySpending&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.share, share) || other.share == share)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,categoryId,name,icon,colorValue,totalCents,share,count);
}

@override
String toString() {
    return 'CategorySpending(categoryId: $categoryId, name: $name, icon: $icon, colorValue: $colorValue, totalCents: $totalCents, share: $share, count: $count)';
}


}

/// @nodoc
abstract mixin class _$CategorySpendingCopyWith<$Res> implements $CategorySpendingCopyWith<$Res> {
  factory _$CategorySpendingCopyWith(_CategorySpending value, $Res Function(_CategorySpending) _then) = __$CategorySpendingCopyWithImpl;
@override @useResult
$Res call({
 int categoryId, String name, String icon, int colorValue, int totalCents, double share, int count
});




}
/// @nodoc
class __$CategorySpendingCopyWithImpl<$Res>
    implements _$CategorySpendingCopyWith<$Res> {
  __$CategorySpendingCopyWithImpl(this._self, this._then);

  final _CategorySpending _self;
  final $Res Function(_CategorySpending) _then;

/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? name = null,Object? icon = null,Object? colorValue = null,Object? totalCents = null,Object? share = null,Object? count = null,}) {
  return _then(_CategorySpending(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TagSpending {

 String get tag; int get totalCents; double get share; int get count;
/// Create a copy of TagSpending
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagSpendingCopyWith<TagSpending> get copyWith => _$TagSpendingCopyWithImpl<TagSpending>(this as TagSpending, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TagSpending;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagSpending&&(identical(other.tag, _this.tag) || other.tag == _this.tag)&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents)&&(identical(other.share, _this.share) || other.share == _this.share)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as TagSpending;
  return Object.hash(runtimeType,_this.tag,_this.totalCents,_this.share,_this.count);
}

@override
String toString() {
  final _this = this as TagSpending;
  return 'TagSpending(tag: ${_this.tag}, totalCents: ${_this.totalCents}, share: ${_this.share}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $TagSpendingCopyWith<$Res>  {
  factory $TagSpendingCopyWith(TagSpending value, $Res Function(TagSpending) _then) = _$TagSpendingCopyWithImpl;
@useResult
$Res call({
 String tag, int totalCents, double share, int count
});




}
/// @nodoc
class _$TagSpendingCopyWithImpl<$Res>
    implements $TagSpendingCopyWith<$Res> {
  _$TagSpendingCopyWithImpl(this._self, this._then);

  final TagSpending _self;
  final $Res Function(TagSpending) _then;

/// Create a copy of TagSpending
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tag = null,Object? totalCents = null,Object? share = null,Object? count = null,}) {
  return _then(TagSpending(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TagSpending].
extension TagSpendingPatterns on TagSpending {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagSpending value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagSpending() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagSpending value)  $default,){
final _that = this;
switch (_that) {
case _TagSpending():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagSpending value)?  $default,){
final _that = this;
switch (_that) {
case _TagSpending() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tag,  int totalCents,  double share,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagSpending() when $default != null:
return $default(_that.tag,_that.totalCents,_that.share,_that.count);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tag,  int totalCents,  double share,  int count)  $default,) {final _that = this;
switch (_that) {
case _TagSpending():
return $default(_that.tag,_that.totalCents,_that.share,_that.count);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tag,  int totalCents,  double share,  int count)?  $default,) {final _that = this;
switch (_that) {
case _TagSpending() when $default != null:
return $default(_that.tag,_that.totalCents,_that.share,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _TagSpending implements TagSpending {
  const _TagSpending({required this.tag, required this.totalCents, required this.share, required this.count});
  

@override final  String tag;
@override final  int totalCents;
@override final  double share;
@override final  int count;

/// Create a copy of TagSpending
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagSpendingCopyWith<_TagSpending> get copyWith => __$TagSpendingCopyWithImpl<_TagSpending>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagSpending&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.share, share) || other.share == share)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tag,totalCents,share,count);
}

@override
String toString() {
    return 'TagSpending(tag: $tag, totalCents: $totalCents, share: $share, count: $count)';
}


}

/// @nodoc
abstract mixin class _$TagSpendingCopyWith<$Res> implements $TagSpendingCopyWith<$Res> {
  factory _$TagSpendingCopyWith(_TagSpending value, $Res Function(_TagSpending) _then) = __$TagSpendingCopyWithImpl;
@override @useResult
$Res call({
 String tag, int totalCents, double share, int count
});




}
/// @nodoc
class __$TagSpendingCopyWithImpl<$Res>
    implements _$TagSpendingCopyWith<$Res> {
  __$TagSpendingCopyWithImpl(this._self, this._then);

  final _TagSpending _self;
  final $Res Function(_TagSpending) _then;

/// Create a copy of TagSpending
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? totalCents = null,Object? share = null,Object? count = null,}) {
  return _then(_TagSpending(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DailySpending {

 DateTime get date; int get totalCents;
/// Create a copy of DailySpending
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailySpendingCopyWith<DailySpending> get copyWith => _$DailySpendingCopyWithImpl<DailySpending>(this as DailySpending, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DailySpending;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailySpending&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents));
}


@override
int get hashCode {
  final _this = this as DailySpending;
  return Object.hash(runtimeType,_this.date,_this.totalCents);
}

@override
String toString() {
  final _this = this as DailySpending;
  return 'DailySpending(date: ${_this.date}, totalCents: ${_this.totalCents})';
}


}

/// @nodoc
abstract mixin class $DailySpendingCopyWith<$Res>  {
  factory $DailySpendingCopyWith(DailySpending value, $Res Function(DailySpending) _then) = _$DailySpendingCopyWithImpl;
@useResult
$Res call({
 DateTime date, int totalCents
});




}
/// @nodoc
class _$DailySpendingCopyWithImpl<$Res>
    implements $DailySpendingCopyWith<$Res> {
  _$DailySpendingCopyWithImpl(this._self, this._then);

  final DailySpending _self;
  final $Res Function(DailySpending) _then;

/// Create a copy of DailySpending
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? totalCents = null,}) {
  return _then(DailySpending(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailySpending].
extension DailySpendingPatterns on DailySpending {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailySpending value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailySpending() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailySpending value)  $default,){
final _that = this;
switch (_that) {
case _DailySpending():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailySpending value)?  $default,){
final _that = this;
switch (_that) {
case _DailySpending() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int totalCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailySpending() when $default != null:
return $default(_that.date,_that.totalCents);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int totalCents)  $default,) {final _that = this;
switch (_that) {
case _DailySpending():
return $default(_that.date,_that.totalCents);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int totalCents)?  $default,) {final _that = this;
switch (_that) {
case _DailySpending() when $default != null:
return $default(_that.date,_that.totalCents);case _:
  return null;

}
}

}

/// @nodoc


class _DailySpending implements DailySpending {
  const _DailySpending({required this.date, required this.totalCents});
  

@override final  DateTime date;
@override final  int totalCents;

/// Create a copy of DailySpending
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailySpendingCopyWith<_DailySpending> get copyWith => __$DailySpendingCopyWithImpl<_DailySpending>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailySpending&&(identical(other.date, date) || other.date == date)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,totalCents);
}

@override
String toString() {
    return 'DailySpending(date: $date, totalCents: $totalCents)';
}


}

/// @nodoc
abstract mixin class _$DailySpendingCopyWith<$Res> implements $DailySpendingCopyWith<$Res> {
  factory _$DailySpendingCopyWith(_DailySpending value, $Res Function(_DailySpending) _then) = __$DailySpendingCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int totalCents
});




}
/// @nodoc
class __$DailySpendingCopyWithImpl<$Res>
    implements _$DailySpendingCopyWith<$Res> {
  __$DailySpendingCopyWithImpl(this._self, this._then);

  final _DailySpending _self;
  final $Res Function(_DailySpending) _then;

/// Create a copy of DailySpending
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? totalCents = null,}) {
  return _then(_DailySpending(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$MonthlySpending {

 DateTime get month; int get totalCents;
/// Create a copy of MonthlySpending
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlySpendingCopyWith<MonthlySpending> get copyWith => _$MonthlySpendingCopyWithImpl<MonthlySpending>(this as MonthlySpending, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MonthlySpending;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlySpending&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents));
}


@override
int get hashCode {
  final _this = this as MonthlySpending;
  return Object.hash(runtimeType,_this.month,_this.totalCents);
}

@override
String toString() {
  final _this = this as MonthlySpending;
  return 'MonthlySpending(month: ${_this.month}, totalCents: ${_this.totalCents})';
}


}

/// @nodoc
abstract mixin class $MonthlySpendingCopyWith<$Res>  {
  factory $MonthlySpendingCopyWith(MonthlySpending value, $Res Function(MonthlySpending) _then) = _$MonthlySpendingCopyWithImpl;
@useResult
$Res call({
 DateTime month, int totalCents
});




}
/// @nodoc
class _$MonthlySpendingCopyWithImpl<$Res>
    implements $MonthlySpendingCopyWith<$Res> {
  _$MonthlySpendingCopyWithImpl(this._self, this._then);

  final MonthlySpending _self;
  final $Res Function(MonthlySpending) _then;

/// Create a copy of MonthlySpending
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? totalCents = null,}) {
  return _then(MonthlySpending(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlySpending].
extension MonthlySpendingPatterns on MonthlySpending {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlySpending value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlySpending() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlySpending value)  $default,){
final _that = this;
switch (_that) {
case _MonthlySpending():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlySpending value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlySpending() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime month,  int totalCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlySpending() when $default != null:
return $default(_that.month,_that.totalCents);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime month,  int totalCents)  $default,) {final _that = this;
switch (_that) {
case _MonthlySpending():
return $default(_that.month,_that.totalCents);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime month,  int totalCents)?  $default,) {final _that = this;
switch (_that) {
case _MonthlySpending() when $default != null:
return $default(_that.month,_that.totalCents);case _:
  return null;

}
}

}

/// @nodoc


class _MonthlySpending implements MonthlySpending {
  const _MonthlySpending({required this.month, required this.totalCents});
  

@override final  DateTime month;
@override final  int totalCents;

/// Create a copy of MonthlySpending
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlySpendingCopyWith<_MonthlySpending> get copyWith => __$MonthlySpendingCopyWithImpl<_MonthlySpending>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlySpending&&(identical(other.month, month) || other.month == month)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,month,totalCents);
}

@override
String toString() {
    return 'MonthlySpending(month: $month, totalCents: $totalCents)';
}


}

/// @nodoc
abstract mixin class _$MonthlySpendingCopyWith<$Res> implements $MonthlySpendingCopyWith<$Res> {
  factory _$MonthlySpendingCopyWith(_MonthlySpending value, $Res Function(_MonthlySpending) _then) = __$MonthlySpendingCopyWithImpl;
@override @useResult
$Res call({
 DateTime month, int totalCents
});




}
/// @nodoc
class __$MonthlySpendingCopyWithImpl<$Res>
    implements _$MonthlySpendingCopyWith<$Res> {
  __$MonthlySpendingCopyWithImpl(this._self, this._then);

  final _MonthlySpending _self;
  final $Res Function(_MonthlySpending) _then;

/// Create a copy of MonthlySpending
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? totalCents = null,}) {
  return _then(_MonthlySpending(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DailyCashflow {

 DateTime get date; int get incomeCents; int get expenseCents;
/// Create a copy of DailyCashflow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyCashflowCopyWith<DailyCashflow> get copyWith => _$DailyCashflowCopyWithImpl<DailyCashflow>(this as DailyCashflow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DailyCashflow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyCashflow&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.incomeCents, _this.incomeCents) || other.incomeCents == _this.incomeCents)&&(identical(other.expenseCents, _this.expenseCents) || other.expenseCents == _this.expenseCents));
}


@override
int get hashCode {
  final _this = this as DailyCashflow;
  return Object.hash(runtimeType,_this.date,_this.incomeCents,_this.expenseCents);
}

@override
String toString() {
  final _this = this as DailyCashflow;
  return 'DailyCashflow(date: ${_this.date}, incomeCents: ${_this.incomeCents}, expenseCents: ${_this.expenseCents})';
}


}

/// @nodoc
abstract mixin class $DailyCashflowCopyWith<$Res>  {
  factory $DailyCashflowCopyWith(DailyCashflow value, $Res Function(DailyCashflow) _then) = _$DailyCashflowCopyWithImpl;
@useResult
$Res call({
 DateTime date, int incomeCents, int expenseCents
});




}
/// @nodoc
class _$DailyCashflowCopyWithImpl<$Res>
    implements $DailyCashflowCopyWith<$Res> {
  _$DailyCashflowCopyWithImpl(this._self, this._then);

  final DailyCashflow _self;
  final $Res Function(DailyCashflow) _then;

/// Create a copy of DailyCashflow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? incomeCents = null,Object? expenseCents = null,}) {
  return _then(DailyCashflow(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,incomeCents: null == incomeCents ? _self.incomeCents : incomeCents // ignore: cast_nullable_to_non_nullable
as int,expenseCents: null == expenseCents ? _self.expenseCents : expenseCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyCashflow].
extension DailyCashflowPatterns on DailyCashflow {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyCashflow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyCashflow() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyCashflow value)  $default,){
final _that = this;
switch (_that) {
case _DailyCashflow():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyCashflow value)?  $default,){
final _that = this;
switch (_that) {
case _DailyCashflow() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int incomeCents,  int expenseCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyCashflow() when $default != null:
return $default(_that.date,_that.incomeCents,_that.expenseCents);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int incomeCents,  int expenseCents)  $default,) {final _that = this;
switch (_that) {
case _DailyCashflow():
return $default(_that.date,_that.incomeCents,_that.expenseCents);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int incomeCents,  int expenseCents)?  $default,) {final _that = this;
switch (_that) {
case _DailyCashflow() when $default != null:
return $default(_that.date,_that.incomeCents,_that.expenseCents);case _:
  return null;

}
}

}

/// @nodoc


class _DailyCashflow extends DailyCashflow {
  const _DailyCashflow({required this.date, required this.incomeCents, required this.expenseCents}): super._();
  

@override final  DateTime date;
@override final  int incomeCents;
@override final  int expenseCents;

/// Create a copy of DailyCashflow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyCashflowCopyWith<_DailyCashflow> get copyWith => __$DailyCashflowCopyWithImpl<_DailyCashflow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyCashflow&&(identical(other.date, date) || other.date == date)&&(identical(other.incomeCents, incomeCents) || other.incomeCents == incomeCents)&&(identical(other.expenseCents, expenseCents) || other.expenseCents == expenseCents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,incomeCents,expenseCents);
}

@override
String toString() {
    return 'DailyCashflow(date: $date, incomeCents: $incomeCents, expenseCents: $expenseCents)';
}


}

/// @nodoc
abstract mixin class _$DailyCashflowCopyWith<$Res> implements $DailyCashflowCopyWith<$Res> {
  factory _$DailyCashflowCopyWith(_DailyCashflow value, $Res Function(_DailyCashflow) _then) = __$DailyCashflowCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int incomeCents, int expenseCents
});




}
/// @nodoc
class __$DailyCashflowCopyWithImpl<$Res>
    implements _$DailyCashflowCopyWith<$Res> {
  __$DailyCashflowCopyWithImpl(this._self, this._then);

  final _DailyCashflow _self;
  final $Res Function(_DailyCashflow) _then;

/// Create a copy of DailyCashflow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? incomeCents = null,Object? expenseCents = null,}) {
  return _then(_DailyCashflow(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,incomeCents: null == incomeCents ? _self.incomeCents : incomeCents // ignore: cast_nullable_to_non_nullable
as int,expenseCents: null == expenseCents ? _self.expenseCents : expenseCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CashflowTransaction {

 int get id; String get title; String get categoryName; String get categoryIcon; int get categoryColorValue; String get accountName; int get amountCents; DateTime get date; bool get isIncome; bool get isTransfer;
/// Create a copy of CashflowTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashflowTransactionCopyWith<CashflowTransaction> get copyWith => _$CashflowTransactionCopyWithImpl<CashflowTransaction>(this as CashflowTransaction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CashflowTransaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashflowTransaction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName)&&(identical(other.categoryIcon, _this.categoryIcon) || other.categoryIcon == _this.categoryIcon)&&(identical(other.categoryColorValue, _this.categoryColorValue) || other.categoryColorValue == _this.categoryColorValue)&&(identical(other.accountName, _this.accountName) || other.accountName == _this.accountName)&&(identical(other.amountCents, _this.amountCents) || other.amountCents == _this.amountCents)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.isIncome, _this.isIncome) || other.isIncome == _this.isIncome)&&(identical(other.isTransfer, _this.isTransfer) || other.isTransfer == _this.isTransfer));
}


@override
int get hashCode {
  final _this = this as CashflowTransaction;
  return Object.hash(runtimeType,_this.id,_this.title,_this.categoryName,_this.categoryIcon,_this.categoryColorValue,_this.accountName,_this.amountCents,_this.date,_this.isIncome,_this.isTransfer);
}

@override
String toString() {
  final _this = this as CashflowTransaction;
  return 'CashflowTransaction(id: ${_this.id}, title: ${_this.title}, categoryName: ${_this.categoryName}, categoryIcon: ${_this.categoryIcon}, categoryColorValue: ${_this.categoryColorValue}, accountName: ${_this.accountName}, amountCents: ${_this.amountCents}, date: ${_this.date}, isIncome: ${_this.isIncome}, isTransfer: ${_this.isTransfer})';
}


}

/// @nodoc
abstract mixin class $CashflowTransactionCopyWith<$Res>  {
  factory $CashflowTransactionCopyWith(CashflowTransaction value, $Res Function(CashflowTransaction) _then) = _$CashflowTransactionCopyWithImpl;
@useResult
$Res call({
 int id, String title, String categoryName, String categoryIcon, int categoryColorValue, String accountName, int amountCents, DateTime date, bool isIncome, bool isTransfer
});




}
/// @nodoc
class _$CashflowTransactionCopyWithImpl<$Res>
    implements $CashflowTransactionCopyWith<$Res> {
  _$CashflowTransactionCopyWithImpl(this._self, this._then);

  final CashflowTransaction _self;
  final $Res Function(CashflowTransaction) _then;

/// Create a copy of CashflowTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? categoryName = null,Object? categoryIcon = null,Object? categoryColorValue = null,Object? accountName = null,Object? amountCents = null,Object? date = null,Object? isIncome = null,Object? isTransfer = null,}) {
  return _then(CashflowTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,categoryIcon: null == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String,categoryColorValue: null == categoryColorValue ? _self.categoryColorValue : categoryColorValue // ignore: cast_nullable_to_non_nullable
as int,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isIncome: null == isIncome ? _self.isIncome : isIncome // ignore: cast_nullable_to_non_nullable
as bool,isTransfer: null == isTransfer ? _self.isTransfer : isTransfer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CashflowTransaction].
extension CashflowTransactionPatterns on CashflowTransaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashflowTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashflowTransaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashflowTransaction value)  $default,){
final _that = this;
switch (_that) {
case _CashflowTransaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashflowTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _CashflowTransaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String categoryName,  String categoryIcon,  int categoryColorValue,  String accountName,  int amountCents,  DateTime date,  bool isIncome,  bool isTransfer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashflowTransaction() when $default != null:
return $default(_that.id,_that.title,_that.categoryName,_that.categoryIcon,_that.categoryColorValue,_that.accountName,_that.amountCents,_that.date,_that.isIncome,_that.isTransfer);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String categoryName,  String categoryIcon,  int categoryColorValue,  String accountName,  int amountCents,  DateTime date,  bool isIncome,  bool isTransfer)  $default,) {final _that = this;
switch (_that) {
case _CashflowTransaction():
return $default(_that.id,_that.title,_that.categoryName,_that.categoryIcon,_that.categoryColorValue,_that.accountName,_that.amountCents,_that.date,_that.isIncome,_that.isTransfer);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String categoryName,  String categoryIcon,  int categoryColorValue,  String accountName,  int amountCents,  DateTime date,  bool isIncome,  bool isTransfer)?  $default,) {final _that = this;
switch (_that) {
case _CashflowTransaction() when $default != null:
return $default(_that.id,_that.title,_that.categoryName,_that.categoryIcon,_that.categoryColorValue,_that.accountName,_that.amountCents,_that.date,_that.isIncome,_that.isTransfer);case _:
  return null;

}
}

}

/// @nodoc


class _CashflowTransaction extends CashflowTransaction {
  const _CashflowTransaction({required this.id, required this.title, required this.categoryName, required this.categoryIcon, required this.categoryColorValue, required this.accountName, required this.amountCents, required this.date, required this.isIncome, required this.isTransfer}): super._();
  

@override final  int id;
@override final  String title;
@override final  String categoryName;
@override final  String categoryIcon;
@override final  int categoryColorValue;
@override final  String accountName;
@override final  int amountCents;
@override final  DateTime date;
@override final  bool isIncome;
@override final  bool isTransfer;

/// Create a copy of CashflowTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashflowTransactionCopyWith<_CashflowTransaction> get copyWith => __$CashflowTransactionCopyWithImpl<_CashflowTransaction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashflowTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIcon, categoryIcon) || other.categoryIcon == categoryIcon)&&(identical(other.categoryColorValue, categoryColorValue) || other.categoryColorValue == categoryColorValue)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.date, date) || other.date == date)&&(identical(other.isIncome, isIncome) || other.isIncome == isIncome)&&(identical(other.isTransfer, isTransfer) || other.isTransfer == isTransfer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,categoryName,categoryIcon,categoryColorValue,accountName,amountCents,date,isIncome,isTransfer);
}

@override
String toString() {
    return 'CashflowTransaction(id: $id, title: $title, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColorValue: $categoryColorValue, accountName: $accountName, amountCents: $amountCents, date: $date, isIncome: $isIncome, isTransfer: $isTransfer)';
}


}

/// @nodoc
abstract mixin class _$CashflowTransactionCopyWith<$Res> implements $CashflowTransactionCopyWith<$Res> {
  factory _$CashflowTransactionCopyWith(_CashflowTransaction value, $Res Function(_CashflowTransaction) _then) = __$CashflowTransactionCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String categoryName, String categoryIcon, int categoryColorValue, String accountName, int amountCents, DateTime date, bool isIncome, bool isTransfer
});




}
/// @nodoc
class __$CashflowTransactionCopyWithImpl<$Res>
    implements _$CashflowTransactionCopyWith<$Res> {
  __$CashflowTransactionCopyWithImpl(this._self, this._then);

  final _CashflowTransaction _self;
  final $Res Function(_CashflowTransaction) _then;

/// Create a copy of CashflowTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? categoryName = null,Object? categoryIcon = null,Object? categoryColorValue = null,Object? accountName = null,Object? amountCents = null,Object? date = null,Object? isIncome = null,Object? isTransfer = null,}) {
  return _then(_CashflowTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,categoryIcon: null == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String,categoryColorValue: null == categoryColorValue ? _self.categoryColorValue : categoryColorValue // ignore: cast_nullable_to_non_nullable
as int,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isIncome: null == isIncome ? _self.isIncome : isIncome // ignore: cast_nullable_to_non_nullable
as bool,isTransfer: null == isTransfer ? _self.isTransfer : isTransfer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
