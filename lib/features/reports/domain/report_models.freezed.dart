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

 int get categoryId; String get name; String get icon; int get colorValue; int get totalCents; double get share;
/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySpendingCopyWith<CategorySpending> get copyWith => _$CategorySpendingCopyWithImpl<CategorySpending>(this as CategorySpending, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategorySpending;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySpending&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.colorValue, _this.colorValue) || other.colorValue == _this.colorValue)&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents)&&(identical(other.share, _this.share) || other.share == _this.share));
}


@override
int get hashCode {
  final _this = this as CategorySpending;
  return Object.hash(runtimeType,_this.categoryId,_this.name,_this.icon,_this.colorValue,_this.totalCents,_this.share);
}

@override
String toString() {
  final _this = this as CategorySpending;
  return 'CategorySpending(categoryId: ${_this.categoryId}, name: ${_this.name}, icon: ${_this.icon}, colorValue: ${_this.colorValue}, totalCents: ${_this.totalCents}, share: ${_this.share})';
}


}

/// @nodoc
abstract mixin class $CategorySpendingCopyWith<$Res>  {
  factory $CategorySpendingCopyWith(CategorySpending value, $Res Function(CategorySpending) _then) = _$CategorySpendingCopyWithImpl;
@useResult
$Res call({
 int categoryId, String name, String icon, int colorValue, int totalCents, double share
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
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? name = null,Object? icon = null,Object? colorValue = null,Object? totalCents = null,Object? share = null,}) {
  return _then(CategorySpending(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int categoryId,  String name,  String icon,  int colorValue,  int totalCents,  double share)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
return $default(_that.categoryId,_that.name,_that.icon,_that.colorValue,_that.totalCents,_that.share);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int categoryId,  String name,  String icon,  int colorValue,  int totalCents,  double share)  $default,) {final _that = this;
switch (_that) {
case _CategorySpending():
return $default(_that.categoryId,_that.name,_that.icon,_that.colorValue,_that.totalCents,_that.share);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int categoryId,  String name,  String icon,  int colorValue,  int totalCents,  double share)?  $default,) {final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
return $default(_that.categoryId,_that.name,_that.icon,_that.colorValue,_that.totalCents,_that.share);case _:
  return null;

}
}

}

/// @nodoc


class _CategorySpending implements CategorySpending {
  const _CategorySpending({required this.categoryId, required this.name, required this.icon, required this.colorValue, required this.totalCents, required this.share});
  

@override final  int categoryId;
@override final  String name;
@override final  String icon;
@override final  int colorValue;
@override final  int totalCents;
@override final  double share;

/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySpendingCopyWith<_CategorySpending> get copyWith => __$CategorySpendingCopyWithImpl<_CategorySpending>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySpending&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.share, share) || other.share == share));
}


@override
int get hashCode {
    return Object.hash(runtimeType,categoryId,name,icon,colorValue,totalCents,share);
}

@override
String toString() {
    return 'CategorySpending(categoryId: $categoryId, name: $name, icon: $icon, colorValue: $colorValue, totalCents: $totalCents, share: $share)';
}


}

/// @nodoc
abstract mixin class _$CategorySpendingCopyWith<$Res> implements $CategorySpendingCopyWith<$Res> {
  factory _$CategorySpendingCopyWith(_CategorySpending value, $Res Function(_CategorySpending) _then) = __$CategorySpendingCopyWithImpl;
@override @useResult
$Res call({
 int categoryId, String name, String icon, int colorValue, int totalCents, double share
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
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? name = null,Object? icon = null,Object? colorValue = null,Object? totalCents = null,Object? share = null,}) {
  return _then(_CategorySpending(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,
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

// dart format on
