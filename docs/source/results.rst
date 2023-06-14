===================================
Output & Results
===================================

Command Line Output
===================
When running the workflow you should see output similar to:

.. code-block:: console

    coming soon

The first line shows the version of Nextflow you are running. The second line shows the version of the workflow
you are running. The third line shows the executor you are using. An executor in Nextflow describes the actual
system the steps of the workflow are running on. In this case the *slurm* computer cluster executor was used.
The next several lines show the actual steps of the workflow as they are running. If a particular step is run
multiple times (e.g., converting many RAW files to mzML using msconvert), the percent complete shows the
percentage of the RAW files that have been converted. The final four lines appear when the workflow completes,
showing the completion time, how long it took, and the number
of steps that succeeded.

Workflow Log
============
The log file called ``.nextflow.log`` will appear in the directory in which the workflow was run. It can be helpful
for determining the cause of any problems. A log file will also be generated for each task executed by the workflow,
which will be described below.

Workflow Results
================
All results will be output to the ``results/nf-teirex-dda`` subdirectory in the directory in which the workflow was
run. In this directory is a subdirectory for each program that was run as part of the workflow. A full description
of output files can be found below.

Output Files
============
Below are each subdirectory created in ``results/nf-teirex-dda`` and a description of files
that will be found in those directories.

``comet`` Subdirectory
^^^^^^^^^^^^^^^^^^^^^^^^^
coming soon

``percolator`` Subdirectory
^^^^^^^^^^^^^^^^^^^^^^^^^^^
coming soon

``limelight`` Subdirectory
^^^^^^^^^^^^^^^^^^^^^^^^^^
coming soon

