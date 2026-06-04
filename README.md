# Matlab-Eigen-benchmark
Questa repository contiene i programmi `C++` e `MATLAB` sviluppati per effettuare i benchmark fra
i due ambienti sulla risoluzione di sistemi lineari sparsi. Il programma C++ è stato sviluppato
utilizzando la libreria open source [Eigen](https://libeigen.gitlab.io/) e sfrutta il risolutore
di sistemi di equazioni lineari tramite metodo di Cholesky offerto dalla libreria `CHOLMOD` di
[SuiteSparse](https://github.com/DrTimothyAldenDavis/SuiteSparse).

## Struttura della repository
La repository contiene le seguenti cartelle:
- `cpp/`: Contiene il progetto C++ sviluppato
- `matlab/`: Contiene il programma MATLAB sviluppato
- `plots/`: Contiene un programma MATLAB per ottenere i grafici sulle prestazioni dei due programmi
- `profilers/`: Contiene due script, uno scritto in linguaggio `bash` e uno in `powershell`, 
   per campionare la memoria rispettivamente su Linux e su Windows.
- `report/`: Contiene il report del progetto

## Compilazione ed esecuzione del programma MATLAB
Per eseguire il programma `MATLAB`, sia su Linux che su Windows, è sufficiente scaricare l'ambiente dal 
[sito ufficiale di Mathworks](https://it.mathworks.com/help/install/ug/install-products-with-internet-connection.html),
clonare questa repository ed eseguire lo script `main.m` presente all'interno della cartella `matlab/`.

## Compilazione ed esecuzione del programma C++
Prima di compilare il programma `C++`, è necessario installare le seguenti dipendenze e i seguenti programmi:
- `Eigen`
- [OpenBLAS con supporto a OpenMP](https://github.com/OpenMathLib/OpenBLAS/blob/develop/docs/install.md)
- `SuiteSparse`
- `cmake`
 ### Linux
L'installazione delle dipendenze e dei programmi richiesti su piattaforma Linux può essere svolta tramite il package
manager della distribuzione. Per esempio, su Fedora, possiamo installarli con il seguente comando:
```bash
$ sudo dnf install eigen3-devel, flexiblas, cmake
```
Una volta installati tutti i software necessari, possiamo utilizzare i seguenti comandi, dalla cartella di root del progetto,
per generare i file di compilazione e compilare il progetto:
```bash
$ sudo cmake -DCMAKE_BUILD_TYPE=Releasem -S ./cpp/ -B ./out/
$ sudo cmake --build ./out/
```
Infine, per eseguire il programma, possiamo eseguire i seguenti comandi:
```bash
$ cd ./out/
$ ./Matlab_Eigen_benchmark
```
### Windows
L’installazione delle dipendenze su piattaforma Windows risulta più complessa a causa della limitata compatibilità di alcune librerie con sistemi non UNIX-like. 

`Eigen` può essere installata tramite il gestore di pacchetti [vcpkg](https://vcpkg.io/en/). Una volta installato `vcpkg`, possiamo utilizzare il seguente
comando, dalla sua cartella di installazione, per installare `Eigen`:
```powershell
$ .\vcpkg.exe install eigen3
```
Purtroppo, non tutte le dipendenze necessarie al progetto sono facilmente ottenibili tramite `vcpkg`:
- Per installare `OpenBLAS` con supporto a `OpenMP`, si consiglia di seguire le istruzioni per la compilazione manuale presentate sulla [documentazione ufficiale di OpenBLAS](https://github.com/OpenMathLib/OpenBLAS/blob/develop/docs/install.md), la quale dettaglia tutti i passaggi necessari a compilare la libreria. Il pacchetto presente su `vcpkg` non è compilato per offrire supporto al multithreading tramite `OpenMP`.
- Per installare `SuiteSparse`, si consiglia di seguire la procedura descritta nella repository [suitesparse-metis-for-windows](https://github.com/jlblancoc/suitesparse-metis-for-windows), la quale fornisce istruzioni dettagliate per la compilazione e l'installazione della libreria tramite `CMake`. La procedura include inoltre indicazioni per integrare correttamente `SuiteSparse` con la versione di `OpenBLAS` precedentemente compilata.

Per eseguire e compilare il programma, infine, si consiglia di installare l'Integrated Development Environment (IDE) [Visual Studio](https://visualstudio.microsoft.com/it/downloads/), il quale permette una gestione più semplificata del processo di compilazione del programma e una migliore integrazione con vcpkg (Visual Studio riconosce automaticamente dove si trovano i pacchetti installati tramite vcpkg). Per poter compilare il programma con Visual Studio, è necessario porre in **Progetto > Modifica set di impostazioni di CMake per <nome_progetto_visual_studio>** la seguente flag alla voce "Argomenti del comando":
```text
  -DCMAKE_PREFIX_PATH=\path\to\OpenBLAS\\install;\path\to\SuiteSparse\build\install
```

