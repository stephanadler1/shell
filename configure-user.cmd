@if not defined _DEBUG echo off

:: -----------------------------------------------------------------------
:: <copyright file="configure-user.cmd" company="Stephan Adler">
:: Copyright (c) Stephan Adler. All Rights Reserved.
:: </copyright>
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
:: 
::     http://www.apache.org/licenses/LICENSE-2.0
:: 
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.
:: -----------------------------------------------------------------------

rem https://www.askvg.com/how-to-change-menu-position-from-left-to-right-in-windows-vista/
call explorer shell:::{80F3F1D5-FECA-45F3-BC32-752C152E456E}
call explorer "%APPDATA%\Microsoft\Windows\Start Menu"
if exist "%SYSTEMDRIVE%\Default\AppData\Roaming\Microsoft\Windows\Start Menu" call explorer "%SYSTEMDRIVE%\Default\AppData\Roaming\Microsoft\Windows\Start Menu"
